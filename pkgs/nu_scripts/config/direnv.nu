# set direnv
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {|| direnv_func})

def-env direnv_func [] {
    let direnv = (direnv export json | from json)
    let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
    $direnv | load-env
}