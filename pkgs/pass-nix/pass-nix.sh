#!@shell@
export PATH=@path@:/run/wrappers/bin/:/usr/bin/:/sbin:/usr/sbin
for key in secrets/.public-keys/*
do
	gpg --import $key 2>/dev/null
done

export PASSWORD_STORE_GPG_OPTS="--trust-model always"
export PASSWORD_STORE_DIR="$PWD/secrets"
pass $@
