module "colmena extern" {
  def "nu-complete colmena apply goal" [] {
    [
      { value: 'build', description: 'Build the configurations only' },
      { value: 'push', description: 'Push the closures only' },
      { value: 'switch', description: 'Make the configuration the boot default and activate now' },
      { value: 'boot', description: 'Make the configuration the boot default' },
      { value: 'test', description: "Activate the configuration, but don't make it the boot default" },
      { value: 'dry-activate', description: "Show what would be done if this configuration were activated" },
      { value: 'upload-keys', description: "Only upload keys" }
    ]
  }

  def "nu-complete colmena apply --evaluator" [] {
    ['chunked', 'streaming']
  }

  def "nu-complete colmena color" [] {
    ['auto', 'always', 'never']
  }

  def "nu-complete colmena on" [
    context: string
  ] {
    let res = (do {
      colmena eval -E '{ nodes, lib, ... }: (lib.attrNames nodes) ++ (map (v: "@${v}") (lib.flatten (lib.mapAttrsToList (_n: n: n.config.deployment.tags) nodes)))'
    } | complete)
    if $res.exit_code != 0 {
      return [ ]
    }
    
    return ($res.stdout | from json)
  }

  # Apply configurations on remote machines
  export extern "colmena apply" [
    --eval-node-limit: any # Evaluation node limit
    --parallel(-p): int # Deploy parallelism limit
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --keep-result # Create GC roots for built profiles
    --nix-option # Passes an arbitrary option to Nix commands
    --verbose(-v) # Be verbose
    --no-keys # Do not upload keys
    --reboot # Reboot nodes after activation
    --no-substitute # Do not use substitutes
    --no-gzip # Do not use gzip
    --build-on-target # Build the system profiles on the target nodes
    --force-replace-unknown-profiles # Ignore all targeted nodes deployment.replaceUnknownProfiles setting
    --evaluator: string@"nu-complete colmena apply --evaluator" # The evaluator to use (experimental)
    --experimental-flake-eval # Use experimental flake evaluator
    --on: string@"nu-complete colmena on" # Node selector
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output 
    goal: string@"nu-complete colmena apply goal" = "switch"
  ]

  # Apply configurations on the local machine
  export extern "colmena apply-local" [
    --sudo # Attempt to escalate privileges if not run as root
    --show-trace # Show debug information for Nix commands
    --verbose(-v) # Deactivates the progress spinner and prints every line of output.
    --impure # Allow impure expressions
    --no-keys # Do not upload keys
    --nix-option # Passes an arbitrary option to Nix commands
    --node: string # Override the node name to use
    --evaluator: string@"nu-complete colmena apply --evaluator" # The evaluator to use (experimental)
    --experimental-flake-eval # Use experimental flake evaluator
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output 
    goal: string@"nu-complete colmena apply goal" = "switch"
  ]

  # Build configurations but not push to remote machines
  export extern "colmena build" [
    --eval-node-limit: any # Evaluation node limit
    --parallel(-p): int # Deploy parallelism limit
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --keep-result # Create GC roots for built profiles
    --nix-option # Passes an arbitrary option to Nix commands
    --verbose(-v) # Be verbose
    --no-keys # Do not upload keys
    --reboot # Reboot nodes after activation
    --no-substitute # Do not use substitutes
    --no-gzip # Do not use gzip
    --build-on-target # Build the system profiles on the target nodes
    --force-replace-unknown-profiles # Ignore all targeted nodes deployment.replaceUnknownProfiles setting
    --evaluator: string@"nu-complete colmena apply --evaluator" # The evaluator to use (experimental)
    --experimental-flake-eval # Use experimental flake evaluator
    --on: string@"nu-complete colmena on" # Node selector
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output 
  ]

  # Evaluate an expression using the complete configuration
  export extern "colmena eval" [
    -E: string # The nix expression
    --instantiate # Actually instantiate the expression
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --nix-option # Passes an arbitrary option to Nix commands
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output
    file?: path # The .nix file containing the expression
  ]

  # Upload keys to remote hosts
  export extern "colmena upload-keys" [
    --eval-node-limit: any # Evaluation node limit
    --parallel(-p): int # Deploy parallelism limit
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --keep-result # Create GC roots for built profiles
    --nix-option # Passes an arbitrary option to Nix commands
    --verbose(-v) # Be verbose
    --no-keys # Do not upload keys
    --reboot # Reboot nodes after activation
    --no-substitute # Do not use substitutes
    --no-gzip # Do not use gzip
    --build-on-target # Build the system profiles on the target nodes
    --force-replace-unknown-profiles # Ignore all targeted nodes deployment.replaceUnknownProfiles setting
    --evaluator: string@"nu-complete colmena apply --evaluator" # The evaluator to use (experimental)
    --on: string@"nu-complete colmena on" # Node selector
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output 
  ]

  # Run a command on remote machines
  export extern "colmena exec" [
    --parallel(-p): int # Deploy parallelism limit
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --nix-option # Passes an arbitrary option to Nix commands
    --on: string@"nu-complete colmena on" # Node selector
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output ]
    ...args: string # Command
  ]
  # Start an interactive REPL with the complete configuration
  export extern "colmena repl" [
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --nix-option # Passes an arbitrary option to Nix commands
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output ]
  ]

  # Show information about the current Nix installation
  export extern "colmena nix-info" [
    --show-trace # Show debug information for Nix commands
    --impure # Allow impure expressions
    --nix-option # Passes an arbitrary option to Nix commands
    --config(-f): string # Path to a Hive expression, a flake.nix, or a Nix Flake URI
    --help(-h) # Print help
    --color: string@"nu-complete colmena color" # When to colorize the output ]
  ]
}
use "colmena extern" *
