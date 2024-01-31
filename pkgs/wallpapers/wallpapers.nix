# Inspired by vika (/u/kisik21) https://gitlab.com/vikanezrimaya/nix-flake
{ lib, stdenvNoCC, curl, jq, gnused, runCommand, fetchurl }:

let
  n = name: v:
    builtins.trace ''
      warning: a NSFW image derivation ${name} is used.
      By building this, you confirm that you are of age to view lewd anime pictures in your country (usually 18 years old) and that it is legal for you to do so.
      If you break the law or hurt your feelings, it's your fault - I assume no responsibility for this.
    '' v;

  fromPixiv = { name ? builtins.baseNameOf url, url, sha256, src, meta ? { } }:
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

in {

  bioshok_big_dady = fromUrl {
    url = "https://i.imgur.com/63nJZTP.jpg";
    sha256 = "sha256-2LucvG3c7qR++0YmQMCp1bzTW6Ta9ezUswOkndBmGlw=";
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

  lost_in_space_mag = fromRedditPost {
    url =
      "https://www.reddit.com/r/WarframeRunway/comments/en4jw5/mag_as_robot_mock_poster_for_lost_in_space_watch/";
    sha256 = "sha256-MJ4OCmiZxvzh0KOwtzjwvPGtoAsCLTy6CqiK2ff28Zw=";
  };

  alita = fromRedditPost {
    url =
      "https://www.reddit.com/r/LargeImages/comments/fk9fcj/7680x4800_alita_battle_angel_rwallpapers/";
    sha256 = "sha256-XYwlqRxJcsLJi/WL/qIseYDkJfKXYofIdC/CE0Hv12U=";
  };

  clouds = fromRedditPost {
    url =
      "https://www.reddit.com/r/wallpapers/comments/g2e2rh/refulgence_2560_x_1440/";
    sha256 = "sha256-MBCsGrSajqJfQB7V7B7zVhH2/SvX98hRq9sL0fOgCV4=";
  };

  argo_ship = fromRedditPost {
    url =
      "https://www.reddit.com/r/StarshipPorn/comments/frh9x4/the_argo_taking_off_from_a_remote_moon_in_the/";
    sha256 = "sha256-lffXq7MJVmbOZj2PG1oKyuR2/4xeTh1+BikRg0yeUMc=";
  };

  city_depth = fromRedditPost {
    url =
      "https://www.reddit.com/r/wallpapers/comments/g0etum/city_depths_by_alec_tucker_3840x2160/";
    sha256 = "sha256-DDzYvFb7ba23HJpyV4lPOBGhq3ZVkFgn6+Iyq5G3QYY=";
  };

  /* bioshock_skycrane = fromRedditPost {
       url = "https://www.reddit.com/r/gaming/comments/87hknr/some_bioshock_wallpapers/";
       sha256 = "sha256-fHJf+XCsSIGscBKTnd05yhceBjZINMJsGgWAD0xsoLs=";
     };
  */

  # https://www.reddit.com/r/lifeisstrange/comments/50wtfd/beautiful_life_is_strange_wallpapers_ive_been/
  life_is_strange_angle = fromUrl {
    url = "https://i.imgur.com/aPfdV47.png";
    name = "life_is_strange_angle";
    sha256 = "sha256-lyeRkNSGapFop+EAJltBWrEtxZ0GARiaAQUL15adwjI=";
  };
  life_is_strange_sense_of_me = fromUrl {
    url = "https://i.imgur.com/Mkwa00q.png";
    name = "life_is_strange_sense_of_me";
    sha256 = "sha256-Gl/stsQItwM3C/5qCBsPMJvUtUBGzyfxvT9Ob1gWvfg=";
  };
  life_is_strange_cloe_angle = fromUrl {
    url = "https://i.imgur.com/SlohViL.png";
    name = "life_is_strange_cloe_angle";
    sha256 = "sha256-/1a8ezIYUsiZE9jhlULLGuuYfNNoEzspdzIZHaqZ/oI=";
  };

  life_is_strange_railway = fromRedditPost {
    name = "life_is_strange_railway";
    url =
      "https://www.reddit.com/r/Thememyxbox/comments/7my729/can_someone_add_this_to_theme_my_xbox_unless/";
    sha256 = "sha256-ZrriNKePp37sel7RGwFO64In9NzNjXIYOlP7MwBkJRc=";
  };
  cloudy_moments = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/f4uu8i/cloudy_moments_your_name_2560x1440/";
    sha256 = "sha256-LtI/StsKwq2HV2VcjfQiRQGPcd099nAoak+eFTPpxT4=";
  };
  one_small_step = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/g253ce/one_small_step_for_man_original_1996x1224/";
    sha256 = "sha256-IXzGOtU21e1EMD84xjqbJtegQp6LuYYmV0p8vH6TDac=";
  };
  falling_stone = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/ahkner/your_name_kimi_no_na_wa_7015x3879/";
    sha256 = "sha256-pi2YmPO2NlooA3lq+UfBNP5VI9ik1uzyBKLj0UKXmFU=";
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
    sha256 = "sha256-GspttvJlK2lZ/dFapic0mKeBI+MnhxUz6VZ9qpgEIvU=";
  };
  lit_fire_angle = fromRedditPost {
    url =
      "https://www.reddit.com/r/Animewallpaper/comments/ftj8br/lit_fire_angle_3840x2160_4k/";
    sha256 = "sha256-Zzy3WrzYiRmmkbD1FSCV2vG0EQmYWRKrQdWcTU7AiGU=";
  };

  # Starcitizen
  sc_downed_man = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/4at3dc1hbnlldr/wallpaper_3840x2160/Source.jpg";
    name = "sc_downed_man";
    sha256 = "sha256-Ek9Q7YiFhk1ZmZGFqEywacR08bYkPyTuAkwM8TeYaWQ=";
  };

  sc_city_mist = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/h3xwsmgo74u42r/wallpaper_3840x2160/Source.jpg";
    name = "sc_city_mist";
    sha256 = "sha256-yU1Y7o5HMvb8maysIzuqzN8cpurTkU8QahGxSMUWlyI=";
  };

  sc_spider_concept = fromUrl {
    url =
      "https://robertsspaceindustries.com/media/8uwxim0jeierqr/source/Spider-Concept-Cathcart.jpg";
    name = "sc_spider_concept";
    sha256 = "sha256-AAKfkqQgBnN+c2+RZfaFoqGeaVzVSc4bmmw37N6198s=";
  };

  # Horizon
  hfw_savana = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8bia.jpg";
    name = "hfw_savanna";
    sha256 = "sha256-F3Ctu8jsknSTSA/BkpjMt4DuJZftJRKjrXOf0l4I1Ao=";
  };

  hfw_turtle = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8c98.jpg";
    name = "hfw_turtle";
    sha256 = "sha256-xIKFciJOlXNz1IfK6NaiF190AilDEsNdSkHexzREdzQ=";
  };

  hfw_flying = fromUrl {
    url = "https://images.igdb.com/igdb/image/upload/t_original/sc8bi9.jpg";
    name = "hfw_flying";
    sha256 = "sha256-nRjhcmnYGovKK6EmQp9YZbYuCUrfFD33Gb0HtOyD8JU=";
  };

  hfw_tallneck_mist = fromUrl {
    url = "https://images7.alphacoders.com/710/710881.jpg";
    name = "hfw_tallneck_mist";
    sha256 = "sha256-kv8HpQxowfwnKWpcZljMATZLhGoquD/dJD8m3n7E7PI=";
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
    name = "hzd_artwork_drawn";
    sha256 = "sha256-zKqcCwrOeodPFsMEBcXffMM8zjrMqsJHVkJh4QgcYMo=";
  };
}
