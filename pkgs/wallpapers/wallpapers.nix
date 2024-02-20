# Inspired by vika (/u/kisik21) https://gitlab.com/vikanezrimaya/nix-flake
{ lib, stdenvNoCC, curl, jq, gnused, runCommand, runCommandNoCC, fetchurl }:

let
  n = name: v:
    builtins.trace ''
      warning: a NSFW image derivation ${name} is used.
      By building this, you confirm that you are of age to view lewd anime pictures in your country (usually 18 years old) and that it is legal for you to do so.
      If you break the law or hurt your feelings, it's your fault - I assume no responsibility for this.
    '' v;

  fromPixiv = { name ? builtins.baseNameOf url, url, sha256 ? lib.fakeHash, src
    , meta ? { } }:
    runCommand name {
      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    } ''
      dir=$out/share/wallpapers/${
        if (if meta ? nsfw then meta.nsfw else false) then
          n name "nsfw/"
        else
          ""
      }/

      mkdir -p $dir
      ${curl}/bin/curl --insecure -H Referer:${src} ${url} > $dir/${name}
    '';

  fromUrl =
    { name ? builtins.baseNameOf url, url, sha256 ? lib.fakeHash, meta ? { } }:
    runCommand name {
      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    } ''
      dir=$out/share/wallpapers/${
        if (if meta ? nsfw then meta.nsfw else false) then
          n name "nsfw/"
        else
          ""
      }/

      mkdir -p $dir
      ${curl}/bin/curl --insecure ${url} > $dir/${name}
    '';

  fromRedditPost = { name ? if (if meta ? nsfw then meta.nsfw else false) then
    ("nsfw-" + (builtins.baseNameOf url))
  else
    (builtins.baseNameOf url), url, sha256, meta ? { } }:
    runCommand name {
      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      inherit meta;
    } ''
      # The post ID is always the 5-th component in the comments link
      postid=$(echo "${url}" | ${gnused}/bin/sed -Ee 's;https?://(www.)?reddit.com;;' | cut -d / -f 5 )
      imageUrl=$(${curl}/bin/curl \
        --insecure \
        --user-agent "NixOS/20.09" \
        -H "Accept: application/json" \
        "https://www.reddit.com/by_id/t3_''${postid}.json" | ${jq}/bin/jq -r ".data.children[0].data.url")

      dir=$out/share/wallpapers/${
        if (if meta ? nsfw then meta.nsfw else false) then
          n name "nsfw/"
        else
          ""
      }/

      mkdir -p $dir
      ${curl}/bin/curl --insecure $imageUrl > $dir/${name}
    '';

  fromFile = { name ? builtins.baseNameOf file, file, meta ? { } }:
    runCommandNoCC name { inherit meta; } ''
      dir=$out/share/wallpapers/${
        if (if meta ? nsfw then meta.nsfw else false) then
          n name "nsfw/"
        else
          ""
      }/

      mkdir -p $dir
      cp ${file} $dir/${name}
    '';

in {

  bioshock_big_dady = fromUrl {
    url = "https://i.imgur.com/63nJZTP.jpg";
    name = "bioshock_big_daddy.jpg";
    sha256 = "sha256-2l0Ixom/+yci4c1IqNFPuCBPpdWlXE2c2Zse9jhfXic=";
  };

  /* kurapika_chains = fromUrl {
       url = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/cb25e9b6-9a51-4021-9332-ce5ba139f5aa/d6v1bax-45f52f8c-e6e3-4a39-967a-ab7bf5a1d6f7.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi9jYjI1ZTliNi05YTUxLTQwMjEtOTMzMi1jZTViYTEzOWY1YWEvZDZ2MWJheC00NWY1MmY4Yy1lNmUzLTRhMzktOTY3YS1hYjdiZjVhMWQ2ZjcuanBnIn1dXX0.0aPZV_qioAMFdvDlKTsqlA77XAij9W-JQUiuiE8f6WE";
       name = "kurapika_chains";
       sha256 = "0000000000000000000000000000000000000000000000000000";
     };
  */

  hisuka_stars = fromUrl {
    url = "https://i.imgur.com/Tas7Ebq.png";
    name = "hisuka_stars.png";
    sha256 = "sha256-yFvv/EAdT0Azb20PndO49mT3fHvVNLeEG2lltvTc9hA=";
  };

  /* hisuka_black_cards = fromUrl {
       url = "https://i.imgur.com/lH6klTI.jpg";
       name = "hisuka_black_cards.jpg";
       sha256 = "sha256-Hqc3om/1B+9yReRXS+S1GPEHiQxxrDspJF3x85wVVK0=";
     };
  */

  /* kilua_blood = fromUrl {
       url =
         "https://www3.picturepush.com/photo/a/11425511/1024/Anonymous/Hunter-x-Hunter---Killua.Zoldyck.full.837345.jpg";
       name = "killua_blood.jpg";
       sha256 = "sha256-PT6GKMAqJtzSSjE03qM1228JcHdO6vNU1kdBDXxhNMU=";
     };
  */

  /* pixiv_city = fromPixiv {
       src = "https://www.pixiv.net/en/artworks/32056860";
       url =
         "https://i.pximg.net/img-master/img/2012/12/12/00/22/50/32056860_p0_master1200.jpg";
       sha256 = "sha256-O0yGBHRniqcKG5+O599ZH7RSVTsH455RtV1Uz1t3O4Q=";
     };
  */

  pixiv_orange = fromPixiv {
    src = "https://www.pixiv.net/en/artworks/68126524";
    url =
      "https://i.pximg.net/img-original/img/2018/07/19/22/57/08/68126524_p0.jpg";
    sha256 = "sha256-iG/6LrIt28CIfh7/7nWdnxt0UXeNMErfvv4X3ShfYbw=";
  };

  pixiv-72175872 = fromPixiv {
    src = "https://www.pixiv.net/en/artworks/72175872";
    url =
      "https://i.pximg.net/img-original/img/2018/12/19/00/00/04/72175872_p0.jpg";
    sha256 = "sha256-KjQj9K9hU6iz6Nu9HmFz2g1taDnbit4tlo/fe4GRlNU=";
  };

  pixiv_bioshock_anime = fromPixiv {
    src = "https://www.pixiv.net/en/artworks/588905";
    url =
      "https://i.pximg.net/img-master/img/2008/03/28/13/22/30/588905_p0_master1200.jpg";
    sha256 = "sha256-O0yGBHRniqcKG5+O599ZH7RSVTsH455RtV1Uz1t3O4Q=";
  };

  pixiv_anime_tram = fromPixiv {
    src = "https://www.pixiv.net/en/artworks/106031896";
    url =
      "https://i.pximg.net/img-master/img/2023/03/08/21/28/06/106031896_p0_master1200.jpg";
    name = "catzz_lil_lull.jpg";
    sha256 = "sha256-+/6enwgmTY4De0aGwpr29K/ivPdhdywBvHFhzD16n+c=";
  };

  pixiv_anime_city_cat = fromPixiv {
    src = "https://www.pixiv.net/en/artworks/113114668";
    url =
      "https://i.pximg.net/img-master/img/2023/11/04/00/30/00/113114668_p0_master1200.jpg";
    name = "catzz_city_cat.jpg";
    sha256 = "sha256-z/bX0qe+X0rOLt14V2eGY8NFx2tqlkIT4kWFhBU+vY8=";
  };

  lost_in_space_mag = fromRedditPost {
    url =
      "https://www.reddit.com/r/WarframeRunway/comments/en4jw5/mag_as_robot_mock_poster_for_lost_in_space_watch/";
    name = "lost_in_space_mag_robot.jpeg";
    sha256 = "sha256-D6/T4kiBUCnDzJmYhTac3gq9TDX15Geu/8BZ9qsSPQg=";
  };

  alita = fromRedditPost {
    url =
      "https://www.reddit.com/r/LargeImages/comments/fk9fcj/7680x4800_alita_battle_angel_rwallpapers/";
    name = "alita_poster.jpeg";
    sha256 = "sha256-zoEp3s00BKCqk6dgHoVm8nKKsZnj2eWs4qEThjeWCsM=";
  };

  clouds = fromRedditPost {
    url =
      "https://www.reddit.com/r/wallpapers/comments/g2e2rh/refulgence_2560_x_1440/";
    name = "refulgence_clouds.png";
    sha256 = "sha256-jmL4VTqhSk1BsSOtCJscvoxgiFPyP8snuAoWcITPdDc=";
  };

  argo_ship = fromRedditPost {
    url =
      "https://www.reddit.com/r/StarshipPorn/comments/frh9x4/the_argo_taking_off_from_a_remote_moon_in_the/";
    name = "sc_argo_taking_of.jpeg";
    sha256 = "sha256-EY1ucFt2PsCXl/Ar6+n8FWcvlw4XoW7lIx1kiuzbU7Y=";
  };

  city_depth = fromRedditPost {
    url =
      "https://www.reddit.com/r/wallpapers/comments/g0etum/city_depths_by_alec_tucker_3840x2160/";
    name = "steampunk_city_depths.png";
    sha256 = "sha256-uC+RX+igJ0pyQvF9QHLTttTvag1lI054QfjFGm6ocgw=";
  };

  /* bioshock_skycrane = fromRedditPost {
       url = "https://www.reddit.com/r/gaming/comments/87hknr/some_bioshock_wallpapers/";
       sha256 = "sha256-fHJf+XCsSIGscBKTnd05yhceBjZINMJsGgWAD0xsoLs=";
     };
  */

  # https://www.reddit.com/r/lifeisstrange/comments/50wtfd/beautiful_life_is_strange_wallpapers_ive_been/
  life_is_strange_angle = fromUrl {
    url = "https://i.imgur.com/aPfdV47.png";
    name = "life_is_strange_angle.png";
    sha256 = "sha256-zbjMST2KGczbxlVOyMsWG9SlWt3Ce88Xcq/qGvYBHX0=";
  };
  life_is_strange_sense_of_me = fromUrl {
    url = "https://i.imgur.com/Mkwa00q.png";
    name = "life_is_strange_sense_of_me.png";
    sha256 = "sha256-s0V6n0OvURbu5gbGKBGyrghA6Wo1PV2SmdwGiU7AD9Q=";
  };
  life_is_strange_cloe_angle = fromUrl {
    url = "https://i.imgur.com/SlohViL.png";
    name = "life_is_strange_cloe_angle.png";
    sha256 = "sha256-4m8Zrywv2PMOYcVsS1m8hafR5HvU6FiqQDzWZYobnjM==";
  };

  life_is_strange_railway = fromRedditPost {
    name = "life_is_strange_railway.jpeg";
    url =
      "https://www.reddit.com/r/Thememyxbox/comments/7my729/can_someone_add_this_to_theme_my_xbox_unless/";
    sha256 = "sha256-+i+x6lxvhVi+1N3hoiEA0Eo4UCmNfYz1HI7vVAGU3Uo=";
  };
  cloudy_moments = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/f4uu8i/cloudy_moments_your_name_2560x1440/";
    name = "your_name_cloudy_moments.png";
    sha256 = "sha256-61J0jjugMta2IVoDKpzUX8WiwF1+nvhSnVzi2OcoLlo=";
  };
  one_small_step = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/g253ce/one_small_step_for_man_original_1996x1224/";
    name = "one_small_step.jpeg";
    sha256 = "sha256-4J1tvnardeVng4+CeCrPUI9H85dpjFSomhc7tUWboCs=";
  };
  falling_stone = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/ahkner/your_name_kimi_no_na_wa_7015x3879/";
    name = "your_name_meteors.jpeg";
    sha256 = "sha256-XZ7QkZfhZ2ZONuLOrDfh4L2qDXGAVDEpWMCYK2THvlM=";
  };
  /* go_home = fromRedditPost {
       url =
         "https://www.reddit.com/r/Animewallpaper/comments/fzjd8i/lets_go_home_original_3840x2160/";
       sha256 = "sha256-Gtvp2RW9okF6cx+0jp+FSFpsTYkliNhBF7J+kp56ZnQ=";
     };
  */
  the_remaining_4_minutes = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/fsvzsg/the_remaining_4_minutes_original_2560x1440/";
    name = "the_remaining_4_minutes.png";
    sha256 = "sha256-qsVTWKBrxmtaeAVPf8nQXfscd3H5+BKDzFRNxjKEbmU=";
  };
  lit_fire_angle = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/ftj8br/lit_fire_angle_3840x2160_4k/";
    name = "lit_fire_angle.jpeg";
    sha256 = "sha256-+cAUWaIKs5MVZUMUtx4n8k61dM/4mDEiWGRLFW+g1aQ=";
  };

  # Starcitizen
  sc_downed_man = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/4at3dc1hbnlldr/wallpaper_3840x2160/Source.jpg";
    name = "sc_downed_man.jpg";
    sha256 = "sha256-U/d+hlIWNFFauOnjPX2aNALHL+lohaK+YgBqcL64qzs=";
  };

  sc_city_mist = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/h3xwsmgo74u42r/wallpaper_3840x2160/Source.jpg";
    name = "sc_city_mist.jpg";
    sha256 = "sha256-SeRs4cSmDfe9yViSNSOGaHIz88nB4qzGenFGL7rBzfE=";
  };

  sc_spider_concept = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/8uwxim0jeierqr/source/Spider-Concept-Cathcart.jpg";
    name = "sc_spider_concept.jpg";
    sha256 = "sha256-YHWKaFEb7njFZdyxFj/Mwivtl0TLqvH2NJZ5CbkqwDg=";
  };

  # Horizon
  hfw_savana = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8bia.jpg";
    name = "hfw_savanna.jpg";
    sha256 = "sha256-0qoMyYbcakyc+nGDEUvBeIitjEVZlAD6ibopgtG1X84=";
  };

  hfw_turtle = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8c98.jpg";
    name = "hfw_turtle.jpg";
    sha256 = "sha256-UGsbPmegCif+yW2LTFh9WAWSXv1VKncoWjUrOX26AOY=";
  };

  hfw_flying = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8bi9.jpg";
    name = "hfw_flying.jpg";
    sha256 = "sha256-YmNODmE3xGPavp414V+iK1NC9y5FRdoM1GJvm9TZ1v8=";
  };

  hfw_tallneck_mist = fromUrl {
    url = "https://images7.alphacoders.com/710/710881.jpg";
    name = "hfw_tallneck_mist.jpg";
    sha256 = "sha256-gn3POLKjUitcLO+gHh7KejSCltmk5KPirfPM4qKYMAY=";
  };

  # To low qualy
  /* hzd_undeground_bunker = fromUrl {
       url = "https://cdna.artstation.com/p/assets/images/images/005/795/128/large/underground-guerrilla-bunker-ss-11-1080.jpg";
       name = "hzd_underground_bunker";
       sha256 = "sha256-nVYRcXKLJpIX5a1RgmOD7rmsLeMPXlA6zjvVtiCwQV0=";
     };
  */
  hzd_artwork_drawn = fromUrl {
    url = "https://i.imgur.com/8tAtF47.jpeg";
    name = "hzd_artwork_drawn.jpeg";
    sha256 = "sha256-rUE0couCbiTIZQI7mPBeo5JAtne/6Oymx+5tpQ/7kFQ=";
  };

  antonov = fromFile { file = ./images/antonov.jpg; };
  cool-space = fromFile { file = ./images/cool-space.png; };
  river = fromFile { file = ./images/river.png; };
  sao = fromFile { file = ./images/sao.png; };
  sea_clouds = fromFile { file = ./images/sea_clouds.jpg; };
  mountain_clouds = fromFile { file = ./images/mountain_clouds.jpg; };
  spaceship_sun_wide = fromFile { file = ./images/2001_ship_sun_wide.png; };
}
