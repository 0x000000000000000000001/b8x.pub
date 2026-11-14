#!/bin/bash
#
# $1 is the env name (e.g. DICT_ORGANIZATION_PJ_FINDER)
#

swarmMode() {
    [[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" == 'active' ]] && echo 1 || echo 0
}

if [[ "$(swarmMode)" == '1' ]]; then
    service_names=$(docker service ls --format '{{.Name}}')
    for service_name in $service_names; do
        if [[ "$service_name" == *'_env' || "$service_name" == *'-env' ]]; then
            env_service_name=$service_name
        fi
    done

    [[ "$env_service_name" == '' ]] && exit

    envs=$(docker service inspect $env_service_name | jq -r '.[0].Spec.TaskTemplate.ContainerSpec.Env[] | @base64')
else
    container_names=$(docker ps --format '{{.Names}}')
    for container_name in $container_names; do
        if [[ "$container_name" == *'_env_1' || "$container_name" == *'-env-1' ]]; then
            env_container_name=$container_name
        fi
    done

    [[ "$env_container_name" == '' ]] && exit

    envs=$(docker container inspect $env_container_name | jq -r '.[0].Config.Env[] | @base64')
fi

for env in $envs; do
    env="$(echo $env | base64 -d)"

    name="$(echo "$env" | cut -d'=' -f1 | tr -d '\n\r')"
    value="$(echo "$env" | cut -d'=' -f2- | tr -d '\n\r')"

    #echo $name
    #echo $value

    [[ "$name" == "$1" ]] && echo $value
done