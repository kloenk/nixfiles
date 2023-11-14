# set direnv
$env.config = ($env | select config -i | upsert
  hooks {
    pre_prompt: [{ ||
      if (which direnv | is-empty) {
        return
      }

      direnv export json | from json | default {} | load-env
    }]
  })

