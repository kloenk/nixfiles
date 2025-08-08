module "west external" {
  const BOARDS_DESCRIPTION = "{name} ({qualifiers}) {vendor}"
  
  def "nu-complete west boards" [context: string] {
    let search = $context | split row " " | last
    let res = (do { west boards -f $"{name}\t($BOARDS_DESCRIPTION)" -n $search} | complete)
    if $res.exit_code != 0 {
      return [ ]
    }

    return ($res.stdout | split row "\n" | split column -n 2 "\t" | each { |d| {value: $d.column1, description: ($d | get -o column2) }})
  }
  
  def "nu-complete west shields" [context: string] {
    let search = $context | split row " " | last
    let res = (do { west shields -f "{name}\t{name}" -n $search} | complete)
    if $res.exit_code != 0 {
      return [ ]
    }

    return ($res.stdout | split row "\n" | split column -n 2 "\t" | each { |d| {value: $d.column1, description: ($d | get -o column2) }})
  }

  def "nu-complete west build --target" [context: string] {
    let context = ($context | split row " ")
    let context = ($context | first (($context | length ) - 1))
    let context = ($context | last (($context | length) - 1))

    let res = (do { west ...$context help  } | complete)
    if $res.exit_code != 0 {
      return [ ]
    }
    let res = ($res.stdout | split row "\n")
    let res = ($res | last (($res | length) - 2))
    return ($res | split column -n 2 ":" | each { |d| { value: $d.column1, description: ($d | get -o column2) }})
  }

  def "nu-complete west build --pristine" [] {
    ["auto", "always", "never"]
  }

  def "nu-complete west sign --tool" [] {
    ["imagetool", "rimage"]
  }
  
  # The Zephyr RTOS meta-tool.
  export extern "west" [
    --zephyr-base(-z): path # Override the Zephyr base directory. The default is the manifest project with path "zephyr".
    --verbose(-v) # Display verbose output. May be given multiple times to increase verbosity.
    --version(-V) # Print the program version and exit.
    ...args: any
  ]

  # Display information about boards
  # FORMAT STRINGS
  # ----------
  # Boards are listed using a Python 3 format string. Arguments
  # to the format string are accessed by name.
  # The default format string is:
  # "{name}"
  # The following arguments are available:
  # - name: board name
  # - qualifiers: board qualifiers (will be empty for legacy boards)
  # - arch: board architecture (deprecated)
  #         (arch is ambiguous for boards described in new hw model)
  # - dir: directory that contains the board definition
  # - vendor: board vendor
  export extern "west boards" [
    --help(-h) # Show this help message
    --format(-f): string # Format string to use to list each board; see FORMAT STRINGS above.
    --name(-n): string # a regular expression; only boards whose names match will be listed
    --arch-root: path # add an architecture root, may be given more than once
    --board-root: path # add a board root, may be given more than once
    --soc-root: path # add a soc root, may be given more than once
    --board: string@"nu-complete west boards" # lookup the specific board, fail if not found
    --board-dir: path # Only look for boards at the specific location
  ]

  # Display supported shields
  # FORMAT STRINGS
  # --------------
  # Shields are listed using a Python 3 format string. Arguments
  # to the format string are accessed by name.
  # The default format string is:
  # "{name}"
  # The following arguments are available:
  # - name: shield name
  # - dir: directory that contains the shield definition
  export extern "west shields" [
    --help(-h) # Show this help message
    --format(-f): string # Format string to use to list each shield; see FORMAT STRINGS
    --name(-n): string # a regular expression; only shields whose names match will be listed
    --board-root: path # add a board root, may be given more than once
  ]
  
  # Convenience wrapper for building Zephyr applications.
  # If the build directory is not given, the default is build/ unless the
  # build.dir-fmt configuration variable is set. The current directory is
  # checked after that. If either is a Zephyr build directory, it is used.
  export extern "west build" [
    --help(-h) # Show this help message
    --board(-b): string@"nu-complete west boards" # board to build for with optional board revision
    --build-dir(-d): path # build directory to create or use
    --force(-f) # ignore any errors nd try to proceed
    --sysbuild # create multi domain build system
    --no-sysbuild # do not create multi domain build system (default)
    # cmake and build tool:
    --cmake(-c) # force a cmake run
    --cmake-only # just run cmake; don't build (implies -c)
    --domain: string # execute build tool (make or ninja) only for given domain
    --target(-t): string@"nu-complete west build --target" # run build system target
    --test-item(-T): string # Build based on test data in testcase.yaml or sample.yaml. If source directory is not used an argument has to be defines as SOURCE_PATH/TEST_NAME.
    --build-opt(-o): string # options passed to the build too (make or ninja); may be given more than once
    --snippet(-S): string # add the argument to SNIPPET
    --shield: string@"nu-complete west shields" # add the argument to SHIELD
    # pristine builds:
    --pristine(-p): string@"nu-complete west build --pristine"
  ]

  # This command automates some of the drudgery of creating signed Zephyr
  # binaries for chain-loading by a bootloader.
  export extern "west sign" [
    --help(-h) # Show this help message
    --build-dir(-d): path # If the build directory is not given, the default is build/ unless the build.dir-fmt configuration variable is set. The current directory is checked after that. If either is a Zephyr build directory, it is used.
    --quiet(-q) # supress non-error output
    --force(-f) # ignore any errors and try to proceed
    # tool control options:
    --tool(-t): string@"nu-complete west sign --tool" # image singing tool name
    --tool-path(-p): path # path to the tool itesl, if needed
    --tool-data(-D): path # path to a tool-specific data/confirguation directory, if needed
    --if-tool-available # Do not fail if the rimage tool is not found or the rimage signing schema (rimage "target") is not defined in board.cmake.
    ...tool_opt # extra options(s) to pass to the signing tool
    # binary (.bin) file options:
    --bin # produce a signed .bin file
    --no-bin
    --sbin(-B): string # signed .bin file name in the build directory
    # Intel HEX (.hex) file options:
    --hex
    --no-hex
    --shex(-H): string # signed .hex file name in the build directory
  ]

  # Permanently reprogram a board's flash with a new binary.
  export extern "west flash" [
    --help(-h) # Show this help message
    --build-dir(-d): path # If the build directory is not given, the default is build/ unless the build.dir-fmt configuration variable is set. The current directory is checked after that. If either is a Zephyr build directory, it is used.
    --runner(-r): string # override defauilt runner from --build-dir
    --skip-rebuild # do not refresh cmake dependencies first
    --domain: string # execute runner only for a given domain
  ]
}
use "west external" *
