def "nu-complete systemctl units" [] {
    systemctl list-units --all
    | from ssv -a
    | each { |data| $data | str trim }
    | filter { |data| ($data.ACTIVE | is-empty) == false }
    | each { |data| {value: $data.UNIT, description: $data.DESCRIPTION } }
}

def "nu-complete systemctl unit-types" [] {
    systemctl --type help
    | from ssv -a
    | each { |data| {value: $data."Available unit types:" }}
}

def "nu-complete systemctl unit-states" [] {
    systemctl --state help
    | from ssv -a -n
    | filter { |data| ($data.column1 | str contains "Available") == false }
    | sort-by column1
    | uniq-by column1
    | each { |state| {value: $state.column1 } }
}

# Start one or more units
export extern "systemctl start" [
    ...units: string@"nu-complete systemctl units"
]

# Stop one or more units
export extern "systemctl stop" [
    ...units: string@"nu-complete systemctl units"
]

# Restart one or more units
export extern "systemctl restart" [
    ...units: string@"nu-complete systemctl units"
]

# Runtime status about one or more units
export extern "systemctl status" [
    ...units: string@"nu-complete systemctl units"
]

# Enable one or more units
export extern "systemctl enable" [
    ...units: string@"nu-complete systemctl units"
]

# Disable one or more units
export extern "systemctl disable" [
    ...units: string@"nu-complete systemctl units"
]

# Start a unit and dependencies and disable all others
export extern "systemctl isolate" [
    ...units: string@"nu-complete systemctl units"
]

# Set the default target to boot into
export extern "systemctl set-default" [

	...args
]

# Sets one or more properties of a unit
export extern "systemctl set-property" [

	...args
]

# List of units
export extern "systemctl list-units" [
    --help (-h) # Show this help
    --version # Show package version
    --system # Connect to system manager
    --user # Connect to user service manager
    --host (-H): string # Operate on remote host
    --machine (-M): string # Operate on a local container
    --type (-t): string@"nu-complete systemctl unit-types" # List units of a particular type
    --state: string@"nu-complete systemctl unit-states" # List units with a particular state
    --failed # Shortcut for --state=failed
    --property (-p): string # Show only properties by this name
    -P: string # Equivalent to --value --property=NAME
    --all (-a) # Show all properties/all units currently in memory, including dead/empty ones. To list all units installed on the system, use 'list-unit-files' instead.
    --full (-l) # Don't ellipsize unit names on output
    --recursive (-r) # Show unit list of host and local containers
    --reverse # Show reverse dependencies with 'list-dependencies'
    --with-dependencies # Show unit dependencies with 'status', 'cat', 'list-units', and 'list-unit-files'.
    --job-mode: string # Specify how to deal with already queued jobs, when queueing a new job
    --show-transaction (-T) # When enqueuing a unit job, show full transaction
    --show-types # When showing sockets, explicitly show their type
    --value # When showing properties, only print the value
    --check-inhibitors: string # Whether to check inhibitors before shutting down, sleeping, or hibernating
    -i # Shortcut for --check-inhibitors=no
    --kill-whom: string # Whom to send signal to
	...args
]

export extern "systemctl" [
    --help (-h) # Show this help
    --version # Show package version
    --system # Connect to system manager
    --user # Connect to user service manager
    --host (-H): string # Operate on remote host
    --machine (-M): string # Operate on a local container
    --type (-t): string@"nu-complete systemctl unit-types" # List units of a particular type
    --state: string@"nu-complete systemctl unit-states" # List units with a particular state
    --failed # Shortcut for --state=failed
    --property (-p): string # Show only properties by this name
    -P: string # Equivalent to --value --property=NAME
    --all (-a) # Show all properties/all units currently in memory, including dead/empty ones. To list all units installed on the system, use 'list-unit-files' instead.
    --full (-l) # Don't ellipsize unit names on output
    --recursive (-r) # Show unit list of host and local containers
    --reverse # Show reverse dependencies with 'list-dependencies'
    --with-dependencies # Show unit dependencies with 'status', 'cat', 'list-units', and 'list-unit-files'.
    --job-mode: string # Specify how to deal with already queued jobs, when queueing a new job
    --show-transaction (-T) # When enqueuing a unit job, show full transaction
    --show-types # When showing sockets, explicitly show their type
    --value # When showing properties, only print the value
    --check-inhibitors: string # Whether to check inhibitors before shutting down, sleeping, or hibernating
    -i # Shortcut for --check-inhibitors=no
    --kill-whom: string # Whom to send signal to
	...args
]

