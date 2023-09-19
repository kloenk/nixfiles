mut nix = {}

# config
source config/direnv.nu
use config/eza.nu *

# commands
use commands/use.nu usex

# completions
use completions/comp-cargo.nu *
use completions/comp-git.nu *
use completions/comp-make.nu *
use completions/comp-nix.nu *
use completions/comp-systemctl.nu *
