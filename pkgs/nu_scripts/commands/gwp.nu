module kloenk/gwp {
  def "gwp-get image attrPath" [
    --kind: string # Kind of image to build (if not in name)
    --variant: string # variant to build if not encoded in name
    name: string # Name of the target to build
  ] {
    if not ($name | str contains ".") {
      return ([ "packages", "images", $name, $kind, $variant ] | str join ".")
    }
    return $name
  }

  def "nu-complete gwp build-image --kind" [] {
    {
      options: {
        sort: false,
      },
      completions: [
        { value: "live", description: "Live image to boot from a USB stick" },
        { value: "base", description: "Base image" },
        { value: "installer", description: "Installer image to boot from a USB stick" }
      ]
    }
  }

  def "nu-complete gwp build-image --variant" [] {
    {
      options: {
        sort: false,
      },
      completions: [
        { value: "debug", description: "Debug image with DRM and debug helpers enabled" },
        { value: "release", description: "Release image with DRM and debug helpers disabled" },
        { value: "release-signed", description: "Signed release image" },
      ]
    }
  }

  export def "gwp build" [
    --file(-f): string = "." # Nix file path to use
    --log-format(-L): string = "multiline-with-logs" # Log format passed to nix
    --keep-going # Keep building if one derivation fails to build
    ...attrPaths
  ] {
    mut nix_args = [ "-f", $file, "--log-format", $log_format, "--no-link", "--json" ]
    if $keep_going {
      $nix_args = ($nix_args | append "--keep-going")
    }
    let drvs = (nix build  ...$nix_args ...$attrPaths | from json)

    return ($drvs | each { get outputs })
  }
  
  export def "gwp build-image" [
    --file(-f): string = "." # Nix file path to use
    --log-format(-L): string = "multiline-with-logs" # Log format passed to nix
    --keep-going # Keep building if one derivation fails to build
    --install # If the image should be installed directly as well
    --installer-attr: string = "legacyPackages.sevenos.installer" # Attr path of the installer
    --installer-bin: string = "sinst" # Path in the installer attr to the binary
    --install-target: string # Device to install the target to
    --sync # Sync after installing
    --kind: string@"nu-complete gwp build-image --kind" = "live" # Kind of image to build (if not in name)
    --variant: string@"nu-complete gwp build-image --variant" = "debug" # variant to build if not encoded in name
    name: string # Name of the target to build
  ] {
    #if $install and $install_target == "" {
    if $install and ($install_target | is-empty) {
      error make {
        msg: "No install target given"
        label: {
	  text: "Install requested but no install target supplied"
	  span: (metadata $install).span
	}
      }
    }
    
    let attrPath = (gwp-get image attrPath --kind=$kind --variant=$variant $name)
    mut buildArgs = [ "--file", $file, "--log-format", $log_format, $attrPath ]
    if $keep_going {
      $buildArgs = ($buildArgs | append "--keep-going")
    }
    if $install {
      $buildArgs = ($buildArgs | append $installer_attr)
    }
    let outPaths = (gwp build ...$buildArgs)
    let imageOut = ($outPaths | get 0.out)

    if not $install {
      return $imageOut
    }

    let installer = ($outPaths | get 1.out)
    let installerBin = ($installer | path join "bin" $installer_bin)
    let installerArgs = [ "--sha256", $"($imageOut)/image.raw.sha256", $"($imageOut)/image.raw.zst", $install_target ]
    try { run-external sudo $installerBin ...$installerArgs } catch { |e|
      error make {
        msg: "Failed to installe"
        label: {
	  text: "Unable to write to target"
	  span: (metadata $install_target).span
	}
      }
    }

    if $sync {
      run-external sync
    }
  }
}
