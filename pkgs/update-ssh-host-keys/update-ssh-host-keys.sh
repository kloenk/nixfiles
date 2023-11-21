#!@shell@

export PATH=@path@

cd "$(git rev-parse --show-toplevel)"

for host in $(nix eval --apply 'attrs: builtins.concatStringsSep "\n" (builtins.filter (name: (name != "defaults")) (builtins.attrNames attrs))' --raw .#nixosConfigurations); do
	echo "$host"
	ssh_key=$(ssh-keyscan -p @port@ -t ed25519 "${host}.@baseDomain@" 2>/dev/null | sed -E 's/(\S+) (.+)/\2/g' || true)
	if [[ -n "$ssh_key" ]]; then
		echo "$ssh_key"
		echo "$ssh_key" > "hosts/${host}/ssh.pub"
	fi
done
