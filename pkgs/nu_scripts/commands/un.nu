module kloenk/un {
  const DEFAULT_FLAKE = "nixpkgs"

  def "nu-complete un package" [ context: string ] {
    let cur = ($context | split row " " | last)
    let res = (do { NIX_GET_COMPLETIONS=2 nix shell $cur} | complete)
    if $res.exit_code != 0 {
      return [ ]
    }

    let comp = ($res.stdout
      | split row "\n" | split column -n 2 "\t"
      | filter { |d| $d.column1 != "normal" and $d.column1 != "attrs" and $d.column1 != "filenames" and $d.column1 != "" }
      | each { |d|
        mut value = ($d | get column1)
	if not ($value | str contains "#") {
	  $value = $value + "#"
	}
        { value: $value, description: ($d | get column2 )}
      }
    )

    if ($cur | str contains "#") {
      return $comp
    } else {
      let res = (do { NIX_GET_COMPLETIONS=2 nix shell $"($DEFAULT_FLAKE)#($cur)"} | complete)
      if $res.exit_code != 0 {
	return $comp
      }

      return ($res.stdout
        | split row "\n" | split column -n 2 "\t"
        | filter { |d| $d.column1 != "normal" and $d.column1 != "attrs" and $d.column1 != "filenames" and $d.column1 != "" }
        | each { |d| { value: ($d | get column1 | str substring (($DEFAULT_FLAKE | str length) + 1)..), description: ($d | get column2 )}}
	| append $comp
      )
    }
  }

  def "nu-complete nix log-format" [] {
    ['raw', 'internal-json', 'bar', 'bar-with-logs', 'multiline', 'multiline-with-logs']
  }


  export def un [
    --flake(-f): string = $DEFAULT_FLAKE # Select a default flake for packages not selecting a flake
    --command(-c): string = "nu" # Command to run
    --impure # Allow access to mutable environment
    --debugger # Start an interactive environment if evaluation fails.
    --log-format: string@'nu-complete nix log-format'    #Set the format of log output; one of raw, internal-json, bar or bar-with-logs.
    --ignore-environment(-i)    #Clear the entire environment (except those specified with --keep).
    ...packages: string@"nu-complete un package" # Packages to install in the temporary shell
  ] {
    let depth = (get_current_depth) + 1
    let package_list = ($packages | each { |package| transform_package $flake $package $depth })

    let extra_args = (if $command == "nu" {
      generate_nu_extra_args $package_list $depth
    } else { "" })

    mut nix_args = [ ]
    if $impure {
      $nix_args = ($nix_args | append "--impure")
    }
    if $debugger {
      $nix_args = ($nix_args | append "--debugger")
    }
    if not ($log_format | is-empty) {
      $nix_args = ($nix_args | append [ "--log-format" $log_format ])
    }
    if $ignore_environment {
      $nix_args = ($nix_args | append "--ignore-environment")
    }

    try {
      nix shell ...$nix_args ...(generate_package_args $package_list) -c $command $extra_args
    } catch { |e|
      error make {
        msg: "Could not find package"
        label: {
          text: "Packages"
	  span: (metadata $packages).span
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

  def generate_package_args [
    packages: list
  ] {
    ($packages | each { |package| $"($package.flake)#($package.package)" })
  }
  
  def generate_nu_extra_args [
    package_list: list
    depth: int
  ] {
    let prev_list = ($env | get -i kloenk.nix.shell.packages)
    let new_list = ($prev_list | append $package_list)

    let execute = $"set-env kloenk {nix: {shell: {depth: ($depth), packages: ($new_list)}}}"

    return $"-e \"($execute)\""
  }
  
  def get_current_depth [] {
    if ($env | get -i kloenk.nix.shell.depth | is-empty) {
      return 0
    } else {
      return $env.kloenk.nix.shell.depth
    }
  }
}
