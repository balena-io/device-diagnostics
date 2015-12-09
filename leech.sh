#!/bin/bash

function fatal()
{
	echo $@ >&2
	exit 1
}

if [ -z "$1" ]; then
    fatal usage: $(basename $0) [device uuid]
fi

if [ ! -f diagnose_template.sh ]; then
    fatal Missing diagnose_template.sh file.
fi

uuid=$1

# Gets current script dir, see http://stackoverflow.com/a/246128.
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
out_dir=${script_dir}/out
out_file=${uuid}.txt
output=${out_dir}/${out_file}

mkdir -p ${out_dir}
rm -rf /tmp/leech
mkdir /tmp/leech

sed "s/@@replaceme@@/$uuid/" ${script_dir}/diagnose_template.sh > /tmp/leech/diagnose.sh

ssh_opts="-o Hostname=$uuid.vpn -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

echo Copying script to device...
scp -q -p $ssh_opts /tmp/leech/diagnose.sh resin:/home/root/ 2>/dev/null
echo Executing script...
ssh $ssh_opts resin "bash /home/root/diagnose.sh" >$output 2>/dev/null
echo Done! Output stored in $out_file
