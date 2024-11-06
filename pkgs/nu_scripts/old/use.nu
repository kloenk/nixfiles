
export def-env usex [
    --flake (-f): string = "kloenk" # Select a default flake for packages not selecting a flake
    --command (-c): string = "nu" # Command to run
    --impure # Allow access to mutable paths and repositories.
    --debugger # Start an interactive environment if evaluation fails.
    ...packages: string # Packages to install in the temporary shell
    ] {
    let depth = (get_current_depth $nix | into int) + 1
    let package_list = ($packages | each { |package| transform_package $flake $package $depth })

    let extra_args = (if $command == nu {
        generate_nu_extra_args $nix $package_list $depth
    } else
      ""
    )
    mut nix_args = []
    if $impure {
        $nix_args = ($nix_args | append "--impure")
    }
    if $debugger {
        $nix_args = ($nix_args | append "--debugger")
    }

    # $nix | select -i "nix_shell_packages" | select 1
    
    try {
    nix shell ($nix_args) (generate_package_args $package_list) -c $command $extra_args
    } catch { |e|
        let span = (metadata $packages).span;
        error make {
            msg: "Could not find package"
            label: {
                text: "Packages"
                start: $span.start
                end: $span.end
            }
        }
    }
}

def transform_package [
    flake: string
    package: string
    depth: int = 0
] {
    if ($package | str contains "#") {
        let package = ($package | split row "#")
        return {flake: $package.0, package: $package.1, depth: $depth}
    } else {
        return {flake: $flake, package: $package, depth: $depth}
    }
}

def generate_package_args [packages: list] {
    return ($packages | each { |package| $"($package.flake)#($package.package)"})
}

def generate_nu_extra_args [
    nix: record
    package_list: list
    depth: int
] {
    let prev_list = ($nix | select -i "nix_shell_packages").nix_shell_packages
    let new_list = ($prev_list | append $package_list)

    let execute = [
        $"$nix.nix_shell_packages = ($new_list)"
        $"$nix.nix_shell_depth = ($depth)"
    ]

    let execute = ($execute | str join ";")

    let args = [
        $"-e \"($execute)\""
    ]

    return $args
}

def get_current_depth [nix: record] {
    if (($nix | select -i "nix_shell_depth").nix_shell_depth | is-empty) {
        return 0
    } else {
        return $nix.nix_shell_depth
    }
}