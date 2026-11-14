#!/bin/bash

base_dir=/etc/traefik

mnt_dir=$base_dir/mnt
mkdir -p $mnt_dir &>/dev/null

dynamic_dir=$mnt_dir/dynamic
mkdir -p $dynamic_dir &>/dev/null

template_file=$base_dir/dynamic/tls.template.yaml

tmp_template_file=$template_file
tmp=$(mktemp)
cat $tmp_template_file > $tmp
echo '' >> $tmp # just in case, empty line at the end
tmp_template_file=$tmp

file=$dynamic_dir/tls.yaml

certs_dir=$base_dir/mnt/certs
! [ -d $certs_dir ] && mkdir -p $certs_dir

export ENV="$(/getenv.sh ENV)"
export SUBDOMAINS="$(/getenv.sh SUBDOMAINS)"
export EXTRA_DOMAINS="$(/getenv.sh EXTRA_DOMAINS)"
export DNS_LEVEL_1="$(/getenv.sh DNS_LEVEL_1)"
export DNS_LEVEL_2="$(/getenv.sh DNS_LEVEL_2)" 
export SWARM_MODE="$(/getenv.sh SWARM_MODE)"

hosts=${DNS_LEVEL_2}.${DNS_LEVEL_1}
for dns_level_3 in $SUBDOMAINS; do
    hosts="${hosts} ${dns_level_3}.${DNS_LEVEL_2}.${DNS_LEVEL_1}"
done
hosts="${hosts} ${EXTRA_DOMAINS}"

# Avoid useless ops if nothing has changed
hash=$(echo "hosts=$hosts+template=$(cat $template_file)" | md5sum | cut -d' ' -f1)
prev_hash=$(cat /.last-domain-certs-hash 2>/dev/null)
echo "prev_hash=$prev_hash"
echo "hash=$hash"
[ "$hash" == "$prev_hash" ] && exit 0

tmp_file=$(mktemp)

cert_files=

while IFS= read -r line; do

    sp="$(echo "$line" | sed -e 's/[a-z].*$//')"

    continue=

    if [[ "$line" == *'rule:'* ]]; then

        hosts_chain=
        for host in $hosts; do
            prefix=
            if [[ "$hosts_chain" != '' ]]; then
                prefix=' || '
            fi

            hosts_chain="${hosts_chain}${prefix}Host(\`$host\`)"
        done

        echo "${sp}rule: '$hosts_chain'" >> $tmp_file
        continue=1

    elif [[ "$line" == *'stores:'* ]]; then
        in_stores=1

    elif [[ "$line" == *'http:'* && "$in_stores" == '1' ]]; then
        in_stores=0

    elif [[ "$line" == *'swebserver:'* ]]; then
        in_swebserver=1

    elif [[ "$line" == *'tls:'* && "$in_swebserver" == "1" ]]; then
        potential_tls_line=$line
        continue=1

    elif [[ "$line" == *'certresolver:'* ]]; then

        if [[ "$SWARM_MODE" != "0" ]]; then
            echo "$potential_tls_line" >> $tmp_file
            echo "$line" >> $tmp_file
            continue=1

            echo "${sp}domains:" >> $tmp_file

            for host in $hosts; do
                echo "${sp}  - main: '$host'" >> $tmp_file
            done
        else
            # In docker (!= swarm) mode, skip appending certresolver and let Traefik use default cert. 
            echo "${potential_tls_line} {}" >> $tmp_file
            continue=1 
        fi
    fi

    if [[ "$SWARM_MODE" != '0' && "$in_stores" == '1' && "$line" != '' ]]; then
        continue=1
    fi

    if [[ "$continue" == '' ]]; then
        echo "$line" >> $tmp_file
    fi

done < $tmp_template_file

echo '' >> $tmp_file # just in case, empty line at the end

touch $file &>/dev/null
cat $tmp_file > $file

#echo -e "Updates $file with:\n $(cat $tmp_file)\n"

rm $tmp_file
rm $tmp_template_file

echo $hash > /.last-domain-certs-hash

# Remove obsolete cert files
for file in $certs_dir/*; do
    if [[ " $cert_files " == *" $file "* ]]; then
        continue
    fi

    rm $file &>/dev/null && echo "Removed obsolete $certs_dir/$file"
done
