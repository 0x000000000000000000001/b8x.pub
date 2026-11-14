#!/bin/bash
#
# Required envs:
#   - $GIT_HOST
#   - $REMOTE
#   - $SOURCE (e.g. docs/public, app...)
#   - $TO
#   - $TZ
#   - $ENV
#   - $PAUSE
# Optional envs:
#   - $SALT
#   - $DEBUG
#

if [[ "$PAUSE" == "1" ]]; then
    echo "Paused. Standing by and doing nothing..."
    tail -f /dev/null
    exit 0
fi

mkdir -p ~/.ssh
ssh-keyscan $GIT_HOST >> ~/.ssh/known_hosts 2>/dev/null

made_dir=0
elapsed_sec=0
max_elapsed_sec=900
sleep_sec=15
loop_nb=0

container=$(cat /etc/hostname)

if [[ "$SOURCE" != "" ]]; then
    # Avoids error such as "Fatal: detected dubious ownership in repository at '/var/www/b8x/...'""
    git config --global --add safe.directory /var/www/b8x/$SOURCE &>/dev/null
fi

# Avoids errors such as "detected dubious ownership in repository at"
git config --global --add safe.directory '*'

# Avoids:
#       hint: Using 'master' as the name for the initial branch. This default branch name
#       hint: is subject to change. To configure the initial branch name to use in all
#       hint: of your new repositories, which will suppress this warning, call:
git config --global init.defaultBranch master &>/dev/null

# We want the code to be manageable by the 1000 user (e.g. admin for AWS)
chown_git() {
    chown -R 1000:1000 .git
}

while true; do
    echo '–––––––––––––––––––––––––––'

    loop_nb=$(( loop_nb + 1 ))

    started_at_human="$(date '+%Y-%m-%d %H:%M') ($TZ)"
    started_at_ts="$(date +%s)"

    # we do it in each loop because the folder could have accidentally been removed between two
    cd /var/www || true

    target_dir=b8x
    if [[ "$SOURCE" != "" ]]; then
        target_dir=b8x/$SOURCE
    fi

    if ! [ -d $target_dir ]; then
        mkdir -p $target_dir
        made_dir=1
    fi
    cd $target_dir || true

    if [[ "$SWARM_MODE" != '0' ]]; then
        echo "Launching a pull (#$loop_nb)... $(date '+%Y-%m-%d %H:%M')"

        if ! [ -d ./.git ]; then
            git init
            git remote add origin $REMOTE

            export PREV_HEAD_COMMIT=
        else
            rm ./.git/index.lock &>/dev/null # just in case

            export PREV_HEAD_COMMIT=$(git rev-parse HEAD)
        fi

        ok=0
        while [[ "$ok" != '1' ]]; do
            tmp=$(mktemp)
            (git fetch --tags --prune --prune-tags --force 2>&1 || true) | tee $tmp # --force is for: https://stackoverflow.com/questions/58031165/how-to-get-rid-of-would-clobber-existing-tag

            # Check if git fetch output contain "The authenticity of host ... can't be established"
            if grep -q 'The authenticity of host' $tmp &>/dev/null; then
                exit 1
            elif grep -q 'Connection reset by peer' $tmp &>/dev/null; then
                ok=0
                sleep 1
            else
                ok=1
            fi

            rm $tmp
        done

        git reset --hard &>/dev/null
        git clean -fq &>/dev/null

        all_branches=$(echo $(git branch --all --format="%(refname:short)"))
        branches=
        for branch in $all_branches; do
            if [[ "$branch" != 'remotes/origin/'* && "$branch" != 'origin/'* ]]; then
                continue
            fi

            branch=$(echo $branch | sed -E -e 's#(remotes/)?origin/##g')

            if [[ "$branches" == '' ]]; then
                branches=$branch
            else
                branches="$branches $branch"
            fi
        done

        # Checkout

        checked_out=0

        for branch in $branches; do
            if [[ "$branch" == "_$ENV" ]]; then
              (git checkout -f origin/_$ENV &>/dev/null) && checked_out=1 && echo "Checked out: _$ENV"
              break
            fi
        done

        if [[ "$checked_out" == '0' ]]; then
            if [[ "$ENV" != 'dev' ]]; then
                for branch in $branches; do
                    if [[ "$branch" == "$ENV" ]]; then
                        (git checkout -f origin/$ENV &>/dev/null) && checked_out=1 && echo "Checked out: $ENV"
                        break
                    fi
                done
            fi

            if [[ "$checked_out" == '0' ]]; then
                match_to=
                if [[ "$TO" == *'*'* ]]; then
                    tags=$(git tag --sort=-version:refname | head -n 10)
                    for tag in $tags; do
                        if [[ "$tag" =~ $TO ]]; then
                            match_to=$tag
                            break
                        fi
                    done

                    if [[ "$match_to" == '' ]]; then
                        for branch in $branches; do
                            if [[ "origin/$branch" =~ $TO || "$branch" =~ $TO ]]; then
                                match_to=origin/$branch
                                break
                            fi
                        done
                    fi

                    if [[ "$match_to" != '' ]]; then
                        match_to_without_origin=$(echo $match_to | sed -E -e 's#(remotes/)?origin/##g')
                        (git checkout -f $match_to &>/dev/null) && checked_out=1 && echo "Checked out: $match_to_without_origin"
                    fi
                fi

                if [[ "$checked_out" == '0' ]]; then
                    to_without_origin=$(echo $TO | sed -E -e 's#(remotes/)?origin/##g')
                    (git checkout -f origin/$to_without_origin &>/dev/null) && checked_out=1 && echo "Checked out: $to_without_origin"

                    if [[ "$checked_out" == '0' ]]; then
                        last_possible_to=master
                        if [[ "$ENV" == 'dev' ]]; then
                            last_possible_to=dev
                        fi

                        (git checkout -f origin/$last_possible_to &>/dev/null) && checked_out=1 && echo "Checked out: $last_possible_to"

                        if [[ "$checked_out" == '0' ]]; then
                            (git checkout -f origin/master &>/dev/null) && checked_out=1 && echo "Checked out: master. Nothing else available."
                        fi
                    fi
                fi
            fi
        fi
    fi

    export HEAD_COMMIT=$(git rev-parse HEAD)

    chown_git &>/dev/null

    if [ -f ./var/.last_pull ]; then
        # shellcheck disable=SC1090
        . <(cat ./var/.last_pull | sed -e 's/^/export /g') &>/dev/null
    fi

    if [ "$made_dir" = '1' ]; then
        export FORCE='-f'
    else
        export FORCE=
    fi

    if [ -f /postpull.sh ]; then
        export SALT
        export OUTPUT_FILE=$(mktemp)

        if [[ "$DEBUG" == '1' ]]; then
            echo "[debug] \$OUTPUT_FILE: $OUTPUT_FILE"
        fi

        if [[ "$SWARM_MODE" != '0' ]]; then
          echo 'Launching post-pull script...'
        else
          echo 'Launching script...'
        fi

        /postpull.sh

        if [[ "$SWARM_MODE" != '0' ]]; then
            chown_git &>/dev/null # just in case (custom /postpull.sh scripts could have played with git too)
        fi

        addon=$(cat $OUTPUT_FILE)

        rm $OUTPUT_FILE
    fi

    # leave a trace of this complete pull process: this will avoid later calls to perform useless heavy ops such as the ones just above
    # this will also be useful for debugging
    if ! [ -d ./var ]; then
        mkdir ./var
    fi
    ended_at_human="$(date '+%Y-%m-%d %H:%M') ($TZ)"
    ended_at_ts="$(date +%s)"
    cat <<ENVS > ./var/.last_pull
LAST_PULL_CONTAINER_ID="$container"
LAST_PULL_STARTED_AT_HUMAN="$started_at_human"
LAST_PULL_STARTED_AT_TS="$started_at_ts"
LAST_PULL_ENDED_AT_HUMAN="$ended_at_human"
LAST_PULL_ENDED_AT_TS="$ended_at_ts"
LAST_PULL_COMMIT="$HEAD_COMMIT"
$addon
ENVS

    if [[ "$SWARM_MODE" != '0' ]]; then
        echo "Sleeping ${sleep_sec}s until the next pull (and watching service update requests, in the meantime)..."
        for i in $(seq 1 $sleep_sec); do
            if [ -d ./var/sock ]; then
                for f in ./var/sock/update_*; do
                    if [ -f "$f" ]; then
                        svc_name=$(basename "$f" | sed 's/update_//')
                        stack_svc=$(docker service ls --format '{{.Name}}' | grep -E "_${svc_name}$" | head -n1)
                        if [ -n "$stack_svc" ]; then
                            echo "Service update was requested. Updating $stack_svc..."
                            (docker service update --force -d "$stack_svc" || true) >/dev/null
                        fi
                        rm -f "$f"
                    fi
                done
            fi
            sleep 1
        done
    else
        echo "Sleeping ${sleep_sec}s..."
        sleep $sleep_sec
    fi

    elapsed_sec=$(( elapsed_sec + sleep_sec ))

    [ $elapsed_sec -ge $max_elapsed_sec ] && exit 0 # Stop when max elapsed time is reached
done