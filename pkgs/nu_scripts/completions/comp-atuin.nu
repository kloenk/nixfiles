
export extern "atuin" [
    --help (-h) # Print help
    --version (-V) # Print version
]

export extern "atuin history" [
    --help (-h) # Print help
]

# Begins a new command in the history

export extern "atuin history start" [
    --help (-h) # Print help
    ...COMMAND
]

# Finishes a new command in the history (adds time, exit code)
export extern "atuin history end" [
    --help (-h) # Print help
    --exit (-e): int
    ID: any
]

# List all items in history
export extern "atuin history list" [
    --help (-h) # Print help
    --cwd (-c)
    --session (-s)
    --human
    --cmd-only # Show only the text of the command
    --format (-f): string
]

# Get the last command ran
export extern "atuin history last" [
    --help (-h) # Print help
    --human
    --cmd-only # Show only the text of the command
    --format (-f): string
]

# Import shell history from file
export extern "atuin import" [
    --help (-h) # Print help
]