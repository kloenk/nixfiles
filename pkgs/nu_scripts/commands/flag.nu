# inspired by schrottkatze
# https://forge.katzen.cafe/schrottkatze/nix-configs/src/commit/6a706007c8d5b2dd3232fd85ed013c7cb85c065d/other/scripts/desktop/shell-startup.nu
module kloenk/flag {
  def "is even" [] {
    $in mod 2 == 0
  }

  const TRANS = [ 5BCEFA F5A9B8 FFFFFF F5A9B8 5BCEFA ];
  const LESBIAN = [ D52D00 EF7627 FF9A56 FFFFFF D162A4 B55690 A30262 ];
  const ENBY = [ FCF434 FFFFFF 9C59D1 2C2C2C ];

  # Print flag from colors list
  export def flag [
    colors: list<string>
    character = "="
    width = -1,
  ] {
    use std;
    
    let out_size = if ($width == -1) {
      term size | get columns
    } else { $width };
    
    let col_size = $out_size / ($colors | length) | math floor;
    mut rest = $out_size - ($col_size * ($colors | length));
    
    mut cols = $colors | wrap color | insert width $col_size | flatten;
    let last = ($colors | length) - 1;
    
    if not ($rest | is even) {
      $rest = $rest - 1;
    
      $cols = (if not ($colors | length | is even) {
        $cols | update (($colors | length) / 2 | math floor) { $in | update width {|w| ($w.width + 1)}}
      } else {
        $cols | update $last { $in | update width {|w| ($w.width + 1)}}
      });
    };
    
    std assert ($rest | is even);
    
    let amount = $rest / 2;
    
    $cols = ($cols | update 0 { $in | update width {|w| ($w.width + $amount) } } | update $last { $in | update width {|w| ($w.width + $amount) } });
    
    $cols | each {|col| 
      $character | std repeat $col.width | prepend (ansi {fg: $"#($col.color)" }) | str join
    } | prepend (ansi attr_bold) | append (ansi reset) | str join
  }

  # Print Trans flag
  export def "flag trans" [
    character = "="
    width = -1,
  ] {
    flag $TRANS
  }

  # Print Lesbian flag
  export def "flag lesbian" [
    character = "="
    width = -1,
  ] {
    flag $LESBIAN
  }

  # Print enby flag
  export def "flag enby" [
    character = "="
    width = -1,
  ] {
    flag $ENBY
  }

}
