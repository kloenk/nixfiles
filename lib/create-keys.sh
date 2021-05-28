#!/usr/bin/env bash
set -euo pipefail

cd $(dirname $0)/..
host=$1

lib_ssh_opts=${LIB_SSH_OPTS:=""}
SSH="ssh $lib_ssh_opts"

function create_key() {
	hostname=$($SSH $1 "hostname")
	echo $hostname
	$SSH $1 "sudo sh -c 'rm -rf /root/.gnupg/*'"
	cat lib/keygen | sed "s/NAME/${hostname}/" | $SSH -o RequestTTY=yes $1 "sudo gpg --generate-key --pinentry-mode loopback --batch /dev/stdin"
	cp ./secrets/.gpg-id ./secrets/$hostname/.gpg-id
	$SSH $1 "sudo -u root gpg --fingerprint --with-colons | grep '^fpr' | head -n1 | cut -d: -f10" >> ./secrets/$hostname/.gpg-id
	$SSH $1 "sudo -u root gpg --export --armor" > ./secrets/.public-keys/$hostname
	lib/pass.sh init -p $hostname $(cat ./secrets/$hostname/.gpg-id);
}

if  [ $host != "" ]; then
	create_key $host
else
	for i in $(cat ./lib/hosts)
	do
		create_key $i
	done
fi
