# set direnv
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {|| direnv_func})

def-env direnv_func [] {
    let direnv = (direnv export json | from json | default {})
    if ($direnv | is-empty) {
        return
    }
    $direnv
    | items {|key, value|
       {
          key: $key
          value: (if $key in $env.ENV_CONVERSIONS {
            do ($env.ENV_CONVERSIONS | get $key | get from_string) $value
          } else {
            $value
          })
        }
    } | transpose -ird | load-env
}