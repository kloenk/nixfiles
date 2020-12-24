{
  gen_state_machine = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "9ac15ec6e66acac994cc442dcc2c6f9796cf380ec4b08267223014be1c728a95";
      url = "https://repo.hex.pm/tarballs/gen_state_machine-2.0.5.tar";
    };
    version = "2.0.5";
  };
  meck = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "ffedb39f99b0b99703b8601c6f17c7f76313ee12de6b646e671e3188401f7866";
      url = "https://repo.hex.pm/tarballs/meck-0.8.13.tar";
    };
    version = "0.8.13";
  };
  phoenix_pubsub = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "a1ae76717bb168cdeb10ec9d92d1480fec99e3080f011402c0a2d68d47395ffb";
      url = "https://repo.hex.pm/tarballs/phoenix_pubsub-2.0.0.tar";
    };
    version = "2.0.0";
  };
  ecto = {
    buildTool = "mix";
    deps = [
      "decimal"
      "jason"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "08f7afad3257d6eb8613309af31037e16c36808dfda5a3cd0cb4e9738db030e4";
      url = "https://repo.hex.pm/tarballs/ecto-3.4.6.tar";
    };
    version = "3.4.6";
  };
  swoosh = {
    buildTool = "mix";
    deps = [
      "cowboy"
      "gen_smtp"
      "hackney"
      "jason"
      "mime"
      "plug_cowboy"
    ];
    fetchHex = {
      sha256 = "6765e334c67dacabe721f0d701c7e5a6f06e4595c90df6f91e73ebd54d555833";
      url = "https://repo.hex.pm/tarballs/swoosh-1.0.6.tar";
    };
    version = "1.0.6";
  };
  plug_crypto = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "1cb20793aa63a6c619dd18bb33d7a3aa94818e5fd39ad357051a67f26dfa2df6";
      url = "https://repo.hex.pm/tarballs/plug_crypto-1.2.0.tar";
    };
    version = "1.2.0";
  };
  unsafe = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "a27e1874f72ee49312e0a9ec2e0b27924214a05e3ddac90e91727bc76f8613d8";
      url = "https://repo.hex.pm/tarballs/unsafe-1.0.1.tar";
    };
    version = "1.0.1";
  };
  cowboy_telemetry = {
    buildTool = "rebar3";
    deps = [
      "cowboy"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "69fdb5cf92df6373e15675eb4018cf629f5d8e35e74841bb637d6596cb797bbc";
      url = "https://repo.hex.pm/tarballs/cowboy_telemetry-0.3.0.tar";
    };
    version = "0.3.0";
  };
  concurrent_limiter = {
    buildTool = "mix";
    fetchGit = {
      rev = "d81be41024569330f296fc472e24198d7499ba78";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/concurrent_limiter.git";
    };
    version = "d81be41024569330f296fc472e24198d7499ba78";
  };
  sweet_xml = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "fc3e91ec5dd7c787b6195757fbcf0abc670cee1e4172687b45183032221b66b8";
      url = "https://repo.hex.pm/tarballs/sweet_xml-0.6.6.tar";
    };
    version = "0.6.6";
  };
  prometheus_phoenix = {
    buildTool = "mix";
    deps = [
      "phoenix"
      "prometheus_ex"
    ];
    fetchHex = {
      sha256 = "c4b527e0b3a9ef1af26bdcfbfad3998f37795b9185d475ca610fe4388fdd3bb5";
      url = "https://repo.hex.pm/tarballs/prometheus_phoenix-1.3.0.tar";
    };
    version = "1.3.0";
  };
  crontab = {
    buildTool = "mix";
    deps = [
      "ecto"
    ];
    fetchHex = {
      sha256 = "2ce0e74777dfcadb28a1debbea707e58b879e6aa0ffbf9c9bb540887bce43617";
      url = "https://repo.hex.pm/tarballs/crontab-1.1.8.tar";
    };
    version = "1.1.8";
  };
  jason = {
    buildTool = "mix";
    deps = [
      "decimal"
    ];
    fetchHex = {
      sha256 = "ba43e3f2709fd1aa1dce90aaabfd039d000469c05c56f0b8e31978e03fa39052";
      url = "https://repo.hex.pm/tarballs/jason-1.2.2.tar";
    };
    version = "1.2.2";
  };
  telemetry = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "2808c992455e08d6177322f14d3bdb6b625fbcfd233a73505870d8738a2f4599";
      url = "https://repo.hex.pm/tarballs/telemetry-0.4.2.tar";
    };
    version = "0.4.2";
  };
  bbcode_pleroma = {
    buildTool = "mix";
    deps = [
      "nimble_parsec"
    ];
    fetchHex = {
      sha256 = "d36f5bca6e2f62261c45be30fa9b92725c0655ad45c99025cb1c3e28e25803ef";
      url = "https://repo.hex.pm/tarballs/bbcode_pleroma-0.2.0.tar";
    };
    version = "0.2.0";
  };
  html_entities = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "1c9715058b42c35a2ab65edc5b36d0ea66dd083767bef6e3edb57870ef556549";
      url = "https://repo.hex.pm/tarballs/html_entities-0.5.1.tar";
    };
    version = "0.5.1";
  };
  base62 = {
    buildTool = "mix";
    deps = [
      "custom_base"
    ];
    fetchHex = {
      sha256 = "4866763e08555a7b3917064e9eef9194c41667276c51b59de2bc42c6ea65f806";
      url = "https://repo.hex.pm/tarballs/base62-1.2.1.tar";
    };
    version = "1.2.1";
  };
  remote_ip = {
    buildTool = "mix";
    fetchGit = {
      rev = "b647d0deecaa3acb140854fe4bda5b7e1dc6d1c8";
      url = "https://git.pleroma.social/pleroma/remote_ip.git";
    };
    version = "b647d0deecaa3acb140854fe4bda5b7e1dc6d1c8";
  };
  phoenix_html = {
    buildTool = "mix";
    deps = [
      "plug"
    ];
    fetchHex = {
      sha256 = "b8a3899a72050f3f48a36430da507dd99caf0ac2d06c77529b1646964f3d563e";
      url = "https://repo.hex.pm/tarballs/phoenix_html-2.14.2.tar";
    };
    version = "2.14.2";
  };
  castore = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "1ca19eee705cde48c9e809e37fdd0730510752cc397745e550f6065a56a701e9";
      url = "https://repo.hex.pm/tarballs/castore-0.1.7.tar";
    };
    version = "0.1.7";
  };
  poison = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "d9eb636610e096f86f25d9a46f35a9facac35609a7591b3be3326e99a0484665";
      url = "https://repo.hex.pm/tarballs/poison-3.1.0.tar";
    };
    version = "3.1.0";
  };
  httpoison = {
    buildTool = "mix";
    deps = [
      "hackney"
    ];
    fetchHex = {
      sha256 = "ace7c8d3a361cebccbed19c283c349b3d26991eff73a1eaaa8abae2e3c8089b6";
      url = "https://repo.hex.pm/tarballs/httpoison-1.6.2.tar";
    };
    version = "1.6.2";
  };
  mogrify = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "9b2496dde44b1ce12676f85d7dc531900939e6367bc537c7243a1b089435b32d";
      url = "https://repo.hex.pm/tarballs/mogrify-0.7.4.tar";
    };
    version = "0.7.4";
  };
  myhtmlex = {
    buildTool = "mix";
    fetchGit = {
      rev = "ad0097e2f61d4953bfef20fb6abddf23b87111e6";
      url = "https://git.pleroma.social/pleroma/myhtmlex.git";
    };
    version = "ad0097e2f61d4953bfef20fb6abddf23b87111e6";
  };
  idna = {
    buildTool = "rebar3";
    deps = [
      "unicode_util_compat"
    ];
    fetchHex = {
      sha256 = "689c46cbcdf3524c44d5f3dde8001f364cd7608a99556d8fbd8239a5798d4c10";
      url = "https://repo.hex.pm/tarballs/idna-6.0.0.tar";
    };
    version = "6.0.0";
  };
  nimble_pool = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "ffa9d5be27eee2b00b0c634eb649aa27f97b39186fec3c493716c2a33e784ec6";
      url = "https://repo.hex.pm/tarballs/nimble_pool-0.1.0.tar";
    };
    version = "0.1.0";
  };
  mochiweb = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "eb55f1db3e6e960fac4e6db4e2db9ec3602cc9f30b86cd1481d56545c3145d2e";
      url = "https://repo.hex.pm/tarballs/mochiweb-2.18.0.tar";
    };
    version = "2.18.0";
  };
  pot = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "61bad869a94534739dd4614a25a619bc5c47b9970e9a0ea5bef4628036fc7a16";
      url = "https://repo.hex.pm/tarballs/pot-0.11.0.tar";
    };
    version = "0.11.0";
  };
  ecto_enum = {
    buildTool = "mix";
    deps = [
      "ecto"
      "ecto_sql"
      "postgrex"
    ];
    fetchHex = {
      sha256 = "d14b00e04b974afc69c251632d1e49594d899067ee2b376277efd8233027aec8";
      url = "https://repo.hex.pm/tarballs/ecto_enum-1.4.0.tar";
    };
    version = "1.4.0";
  };
  hackney = {
    buildTool = "rebar3";
    deps = [
      "certifi"
      "idna"
      "metrics"
      "mimerl"
      "ssl_verify_fun"
    ];
    fetchHex = {
      sha256 = "07e33c794f8f8964ee86cebec1a8ed88db5070e52e904b8f12209773c1036085";
      url = "https://repo.hex.pm/tarballs/hackney-1.15.2.tar";
    };
    version = "1.15.2";
  };
  oban = {
    buildTool = "mix";
    deps = [
      "ecto_sql"
      "jason"
      "postgrex"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "034144686f7e76a102b5d67731f098d98a9e4a52b07c25ad580a01f83a7f1cf5";
      url = "https://repo.hex.pm/tarballs/oban-2.1.0.tar";
    };
    version = "2.1.0";
  };
  fast_html = {
    buildTool = "mix";
    deps = [
      "elixir_make"
      "nimble_pool"
    ];
    fetchHex = {
      sha256 = "4910ee49f2f6b19692e3bf30bf97f1b6b7dac489cd6b0f34cd0fe3042c56ba30";
      url = "https://repo.hex.pm/tarballs/fast_html-2.0.4.tar";
    };
    version = "2.0.4";
  };
  websocket_client = {
    buildTool = "mix";
    fetchGit = {
      rev = "9a6f65d05ebf2725d62fb19262b21f1805a59fbf";
      url = "https://github.com/jeremyong/websocket_client.git";
    };
    version = "9a6f65d05ebf2725d62fb19262b21f1805a59fbf";
  };
  mock = {
    buildTool = "mix";
    deps = [
      "meck"
    ];
    fetchHex = {
      sha256 = "feb81f52b8dcf0a0d65001d2fec459f6b6a8c22562d94a965862f6cc066b5431";
      url = "https://repo.hex.pm/tarballs/mock-0.3.5.tar";
    };
    version = "0.3.5";
  };
  ssl_verify_fun = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "6eaf7ad16cb568bb01753dbbd7a95ff8b91c7979482b95f38443fe2c8852a79b";
      url = "https://repo.hex.pm/tarballs/ssl_verify_fun-1.1.5.tar";
    };
    version = "1.1.5";
  };
  flake_id = {
    buildTool = "mix";
    deps = [
      "base62"
      "ecto"
    ];
    fetchHex = {
      sha256 = "7716b086d2e405d09b647121a166498a0d93d1a623bead243e1f74216079ccb3";
      url = "https://repo.hex.pm/tarballs/flake_id-0.1.0.tar";
    };
    version = "0.1.0";
  };
  fast_sanitize = {
    buildTool = "mix";
    deps = [
      "fast_html"
      "plug"
    ];
    fetchHex = {
      sha256 = "3cbbaebaea6043865dfb5b4ecb0f1af066ad410a51470e353714b10c42007b81";
      url = "https://repo.hex.pm/tarballs/fast_sanitize-0.2.2.tar";
    };
    version = "0.2.2";
  };
  libring = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "41246ba2f3fbc76b3971f6bce83119dfec1eee17e977a48d8a9cfaaf58c2a8d6";
      url = "https://repo.hex.pm/tarballs/libring-1.4.0.tar";
    };
    version = "1.4.0";
  };
  prometheus_plugs = {
    buildTool = "mix";
    deps = [
      "accept"
      "plug"
      "prometheus_ex"
    ];
    fetchHex = {
      sha256 = "25933d48f8af3a5941dd7b621c889749894d8a1082a6ff7c67cc99dec26377c5";
      url = "https://repo.hex.pm/tarballs/prometheus_plugs-1.1.5.tar";
    };
    version = "1.1.5";
  };
  cors_plug = {
    buildTool = "mix";
    deps = [
      "plug"
    ];
    fetchHex = {
      sha256 = "2b46083af45e4bc79632bd951550509395935d3e7973275b2b743bd63cc942ce";
      url = "https://repo.hex.pm/tarballs/cors_plug-2.0.2.tar";
    };
    version = "2.0.2";
  };
  captcha = {
    buildTool = "mix";
    fetchGit = {
      rev = "e0f16822d578866e186a0974d65ad58cddc1e2ab";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/elixir-captcha.git";
    };
    version = "e0f16822d578866e186a0974d65ad58cddc1e2ab";
  };
  syslog = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "6419a232bea84f07b56dc575225007ffe34d9fdc91abe6f1b2f254fd71d8efc2";
      url = "https://repo.hex.pm/tarballs/syslog-1.1.0.tar";
    };
    version = "1.1.0";
  };
  cowboy = {
    buildTool = "rebar3";
    deps = [
      "cowlib"
      "ranch"
    ];
    fetchHex = {
      sha256 = "f3dc62e35797ecd9ac1b50db74611193c29815401e53bac9a5c0577bd7bc667d";
      url = "https://repo.hex.pm/tarballs/cowboy-2.8.0.tar";
    };
    version = "2.8.0";
  };
  makeup = {
    buildTool = "mix";
    deps = [
      "nimble_parsec"
    ];
    fetchHex = {
      sha256 = "e339e2f766d12e7260e6672dd4047405963c5ec99661abdc432e6ec67d29ef95";
      url = "https://repo.hex.pm/tarballs/makeup-1.0.3.tar";
    };
    version = "1.0.3";
  };
  trailing_format_plug = {
    buildTool = "mix";
    deps = [
      "plug"
    ];
    fetchHex = {
      sha256 = "64b877f912cf7273bed03379936df39894149e35137ac9509117e59866e10e45";
      url = "https://repo.hex.pm/tarballs/trailing_format_plug-0.0.7.tar";
    };
    version = "0.0.7";
  };
  majic = {
    buildTool = "mix";
    fetchGit = {
      rev = "4c692e544b28d1f5e543fb8a44be090f8cd96f80";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/majic";
    };
    version = "4c692e544b28d1f5e543fb8a44be090f8cd96f80";
  };
  certifi = {
    buildTool = "rebar3";
    deps = [
      "parse_trans"
    ];
    fetchHex = {
      sha256 = "867ce347f7c7d78563450a18a6a28a8090331e77fa02380b4a21962a65d36ee5";
      url = "https://repo.hex.pm/tarballs/certifi-2.5.1.tar";
    };
    version = "2.5.1";
  };
  ex_aws = {
    buildTool = "mix";
    deps = [
      "hackney"
      "jason"
      "sweet_xml"
    ];
    fetchHex = {
      sha256 = "26b6f036f0127548706aade4a509978fc7c26bd5334b004fba9bfe2687a525df";
      url = "https://repo.hex.pm/tarballs/ex_aws-2.1.3.tar";
    };
    version = "2.1.3";
  };
  cachex = {
    buildTool = "mix";
    deps = [
      "eternal"
      "jumper"
      "sleeplocks"
      "unsafe"
    ];
    fetchHex = {
      sha256 = "a596476c781b0646e6cb5cd9751af2e2974c3e0d5498a8cab71807618b74fe2f";
      url = "https://repo.hex.pm/tarballs/cachex-3.2.0.tar";
    };
    version = "3.2.0";
  };
  jumper = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "3c00542ef1a83532b72269fab9f0f0c82bf23a35e27d278bfd9ed0865cecabff";
      url = "https://repo.hex.pm/tarballs/jumper-1.0.1.tar";
    };
    version = "1.0.1";
  };
  connection = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "a1cae72211f0eef17705aaededacac3eb30e6625b04a6117c1b2db6ace7d5976";
      url = "https://repo.hex.pm/tarballs/connection-1.0.4.tar";
    };
    version = "1.0.4";
  };
  pbkdf2_elixir = {
    buildTool = "mix";
    deps = [
      "comeonin"
    ];
    fetchHex = {
      sha256 = "9cbe354b58121075bd20eb83076900a3832324b7dd171a6895fab57b6bb2752c";
      url = "https://repo.hex.pm/tarballs/pbkdf2_elixir-1.2.1.tar";
    };
    version = "1.2.1";
  };
  quack = {
    buildTool = "mix";
    deps = [
      "poison"
      "tesla"
    ];
    fetchHex = {
      sha256 = "cca7b4da1a233757fdb44b3334fce80c94785b3ad5a602053b7a002b5a8967bf";
      url = "https://repo.hex.pm/tarballs/quack-0.1.1.tar";
    };
    version = "0.1.1";
  };
  bcrypt_elixir = {
    buildTool = "mix";
    deps = [
      "comeonin"
      "elixir_make"
    ];
    fetchHex = {
      sha256 = "3df902b81ce7fa8867a2ae30d20a1da6877a2c056bfb116fd0bc8a5f0190cea4";
      url = "https://repo.hex.pm/tarballs/bcrypt_elixir-2.2.0.tar";
    };
    version = "2.2.0";
  };
  mimerl = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "67e2d3f571088d5cfd3e550c383094b47159f3eee8ffa08e64106cdf5e981be3";
      url = "https://repo.hex.pm/tarballs/mimerl-1.2.0.tar";
    };
    version = "1.2.0";
  };
  bunt = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "951c6e801e8b1d2cbe58ebbd3e616a869061ddadcc4863d0a2182541acae9a38";
      url = "https://repo.hex.pm/tarballs/bunt-0.2.0.tar";
    };
    version = "0.2.0";
  };
  ranch = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "6b1fab51b49196860b733a49c07604465a47bdb78aa10c1c16a3d199f7f8c881";
      url = "https://repo.hex.pm/tarballs/ranch-1.7.1.tar";
    };
    version = "1.7.1";
  };
  metrics = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "25f094dea2cda98213cecc3aeff09e940299d950904393b2a29d191c346a8486";
      url = "https://repo.hex.pm/tarballs/metrics-1.0.1.tar";
    };
    version = "1.0.1";
  };
  calendar = {
    buildTool = "mix";
    deps = [
      "tzdata"
    ];
    fetchHex = {
      sha256 = "f52073a708528482ec33d0a171954ca610fe2bd28f1e871f247dc7f1565fa807";
      url = "https://repo.hex.pm/tarballs/calendar-1.0.0.tar";
    };
    version = "1.0.0";
  };
  floki = {
    buildTool = "mix";
    deps = [
      "html_entities"
    ];
    fetchHex = {
      sha256 = "6b29a14283f1e2e8fad824bc930eaa9477c462022075df6bea8f0ad811c13599";
      url = "https://repo.hex.pm/tarballs/floki-0.27.0.tar";
    };
    version = "0.27.0";
  };
  nodex = {
    buildTool = "mix";
    fetchGit = {
      rev = "cb6730f943cfc6aad674c92161be23a8411f15d1";
      url = "https://git.pleroma.social/pleroma/nodex";
    };
    version = "cb6730f943cfc6aad674c92161be23a8411f15d1";
  };
  earmark_parser = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "6603d7a603b9c18d3d20db69921527f82ef09990885ed7525003c7fe7dc86c56";
      url = "https://repo.hex.pm/tarballs/earmark_parser-1.4.10.tar";
    };
    version = "1.4.10";
  };
  mime = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "5066f14944b470286146047d2f73518cf5cca82f8e4815cf35d196b58cf07c47";
      url = "https://repo.hex.pm/tarballs/mime-1.4.0.tar";
    };
    version = "1.4.0";
  };
  gettext = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "406d6b9e0e3278162c2ae1de0a60270452c553536772167e2d701f028116f870";
      url = "https://repo.hex.pm/tarballs/gettext-0.18.0.tar";
    };
    version = "0.18.0";
  };
  ex_machina = {
    buildTool = "mix";
    deps = [
      "ecto"
      "ecto_sql"
    ];
    fetchHex = {
      sha256 = "09a34c5d371bfb5f78399029194a8ff67aff340ebe8ba19040181af35315eabb";
      url = "https://repo.hex.pm/tarballs/ex_machina-2.4.0.tar";
    };
    version = "2.4.0";
  };
  tzdata = {
    buildTool = "mix";
    deps = [
      "hackney"
    ];
    fetchHex = {
      sha256 = "a3baa4709ea8dba552dca165af6ae97c624a2d6ac14bd265165eaa8e8af94af6";
      url = "https://repo.hex.pm/tarballs/tzdata-1.0.4.tar";
    };
    version = "1.0.4";
  };
  timex = {
    buildTool = "mix";
    deps = [
      "combine"
      "gettext"
      "tzdata"
    ];
    fetchHex = {
      sha256 = "845cdeb6119e2fef10751c0b247b6c59d86d78554c83f78db612e3290f819bc2";
      url = "https://repo.hex.pm/tarballs/timex-3.6.2.tar";
    };
    version = "3.6.2";
  };
  prometheus_ex = {
    buildTool = "mix";
    fetchGit = {
      rev = "a4e9beb3c1c479d14b352fd9d6dd7b1f6d7deee5";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/prometheus.ex.git";
    };
    version = "a4e9beb3c1c479d14b352fd9d6dd7b1f6d7deee5";
  };
  ecto_sql = {
    buildTool = "mix";
    deps = [
      "db_connection"
      "ecto"
      "postgrex"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "30161f81b167d561a9a2df4329c10ae05ff36eca7ccc84628f2c8b9fa1e43323";
      url = "https://repo.hex.pm/tarballs/ecto_sql-3.4.5.tar";
    };
    version = "3.4.5";
  };
  poolboy = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "392b007a1693a64540cead79830443abf5762f5d30cf50bc95cb2c1aaafa006b";
      url = "https://repo.hex.pm/tarballs/poolboy-1.5.2.tar";
    };
    version = "1.5.2";
  };
  prometheus_ecto = {
    buildTool = "mix";
    deps = [
      "ecto"
      "prometheus_ex"
    ];
    fetchHex = {
      sha256 = "3dd4da1812b8e0dbee81ea58bb3b62ed7588f2eae0c9e97e434c46807ff82311";
      url = "https://repo.hex.pm/tarballs/prometheus_ecto-1.4.3.tar";
    };
    version = "1.4.3";
  };
  html_sanitize_ex = {
    buildTool = "mix";
    deps = [
      "mochiweb"
    ];
    fetchHex = {
      sha256 = "f005ad692b717691203f940c686208aa3d8ffd9dd4bb3699240096a51fa9564e";
      url = "https://repo.hex.pm/tarballs/html_sanitize_ex-1.3.0.tar";
    };
    version = "1.3.0";
  };
  eimp = {
    buildTool = "rebar3";
    deps = [
      "p1_utils"
    ];
    fetchHex = {
      sha256 = "fc297f0c7e2700457a95a60c7010a5f1dcb768a083b6d53f49cd94ab95a28f22";
      url = "https://repo.hex.pm/tarballs/eimp-1.0.14.tar";
    };
    version = "1.0.14";
  };
  sleeplocks = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "3d462a0639a6ef36cc75d6038b7393ae537ab394641beb59830a1b8271faeed3";
      url = "https://repo.hex.pm/tarballs/sleeplocks-1.1.1.tar";
    };
    version = "1.1.1";
  };
  gen_smtp = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "9f51960c17769b26833b50df0b96123605a8024738b62db747fece14eb2fbfcc";
      url = "https://repo.hex.pm/tarballs/gen_smtp-0.15.0.tar";
    };
    version = "0.15.0";
  };
  benchee = {
    buildTool = "mix";
    deps = [
      "deep_merge"
    ];
    fetchHex = {
      sha256 = "66b211f9bfd84bd97e6d1beaddf8fc2312aaabe192f776e8931cb0c16f53a521";
      url = "https://repo.hex.pm/tarballs/benchee-1.0.1.tar";
    };
    version = "1.0.1";
  };
  makeup_elixir = {
    buildTool = "mix";
    deps = [
      "makeup"
    ];
    fetchHex = {
      sha256 = "4f0e96847c63c17841d42c08107405a005a2680eb9c7ccadfd757bd31dabccfb";
      url = "https://repo.hex.pm/tarballs/makeup_elixir-0.14.1.tar";
    };
    version = "0.14.1";
  };
  cowlib = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "61a6c7c50cf07fdd24b2f45b89500bb93b6686579b069a89f88cb211e1125c78";
      url = "https://repo.hex.pm/tarballs/cowlib-2.9.1.tar";
    };
    version = "2.9.1";
  };
  prometheus = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "20510f381db1ccab818b4cf2fac5fa6ab5cc91bc364a154399901c001465f46f";
      url = "https://repo.hex.pm/tarballs/prometheus-4.6.0.tar";
    };
    version = "4.6.0";
  };
  postgrex = {
    buildTool = "mix";
    deps = [
      "connection"
      "db_connection"
      "decimal"
      "jason"
    ];
    fetchHex = {
      sha256 = "a464c72010a56e3214fe2b99c1a76faab4c2bb0255cabdef30dea763a3569aa2";
      url = "https://repo.hex.pm/tarballs/postgrex-0.15.6.tar";
    };
    version = "0.15.6";
  };
  linkify = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "2518bbbea21d2caa9d372424e1ad845b640c6630e2d016f1bd1f518f9ebcca28";
      url = "https://repo.hex.pm/tarballs/linkify-0.2.0.tar";
    };
    version = "0.2.0";
  };
  inet_cidr = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "a05744ab7c221ca8e395c926c3919a821eb512e8f36547c062f62c4ca0cf3d6e";
      url = "https://repo.hex.pm/tarballs/inet_cidr-1.0.4.tar";
    };
    version = "1.0.4";
  };
  excoveralls = {
    buildTool = "mix";
    deps = [
      "hackney"
      "jason"
    ];
    fetchHex = {
      sha256 = "2142be7cb978a3ae78385487edda6d1aff0e482ffc6123877bb7270a8ffbcfe0";
      url = "https://repo.hex.pm/tarballs/excoveralls-0.12.3.tar";
    };
    version = "0.12.3";
  };
  tesla = {
    buildTool = "mix";
    fetchGit = {
      rev = "9f7261ca49f9f901ceb73b60219ad6f8a9f6aa30";
      url = "https://github.com/teamon/tesla/";
    };
    version = "9f7261ca49f9f901ceb73b60219ad6f8a9f6aa30";
  };
  comeonin = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "7fe612b739c78c9c1a75186ef2d322ce4d25032d119823269d0aa1e2f1e20025";
      url = "https://repo.hex.pm/tarballs/comeonin-5.3.1.tar";
    };
    version = "5.3.1";
  };
  crypt = {
    buildTool = "mix";
    fetchGit = {
      rev = "f63a705f92c26955977ee62a313012e309a4d77a";
      url = "https://github.com/msantos/crypt.git";
    };
    version = "f63a705f92c26955977ee62a313012e309a4d77a";
  };
  parse_trans = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "09765507a3c7590a784615cfd421d101aec25098d50b89d7aa1d66646bc571c1";
      url = "https://repo.hex.pm/tarballs/parse_trans-3.3.0.tar";
    };
    version = "3.3.0";
  };
  ex_aws_s3 = {
    buildTool = "mix";
    deps = [
      "ex_aws"
      "sweet_xml"
    ];
    fetchHex = {
      sha256 = "c0258bbdfea55de4f98f0b2f0ca61fe402cc696f573815134beb1866e778f47b";
      url = "https://repo.hex.pm/tarballs/ex_aws_s3-2.0.2.tar";
    };
    version = "2.0.2";
  };
  accept = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "b33b127abca7cc948bbe6caa4c263369abf1347cfa9d8e699c6d214660f10cd1";
      url = "https://repo.hex.pm/tarballs/accept-0.3.5.tar";
    };
    version = "0.3.5";
  };
  web_push_encryption = {
    buildTool = "mix";
    deps = [
      "httpoison"
      "jose"
    ];
    fetchHex = {
      sha256 = "598b5135e696fd1404dc8d0d7c0fa2c027244a4e5d5e5a98ba267f14fdeaabc8";
      url = "https://repo.hex.pm/tarballs/web_push_encryption-0.3.0.tar";
    };
    version = "0.3.0";
  };
  prometheus_phx = {
    buildTool = "mix";
    fetchGit = {
      rev = "9cd8f248c9381ffedc799905050abce194a97514";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/prometheus-phx.git";
    };
    version = "9cd8f248c9381ffedc799905050abce194a97514";
  };
  phoenix_swoosh = {
    buildTool = "mix";
    deps = [
      "hackney"
      "phoenix"
      "phoenix_html"
      "swoosh"
    ];
    fetchHex = {
      sha256 = "43d3518349a22b8b1910ea28b4dd5119926d5017b3187db3fbd1a1e05769a851";
      url = "https://repo.hex.pm/tarballs/phoenix_swoosh-0.3.2.tar";
    };
    version = "0.3.2";
  };
  ex_doc = {
    buildTool = "mix";
    deps = [
      "earmark_parser"
      "makeup_elixir"
    ];
    fetchHex = {
      sha256 = "03a2a58bdd2ba0d83d004507c4ee113b9c521956938298eba16e55cc4aba4a6c";
      url = "https://repo.hex.pm/tarballs/ex_doc-0.22.2.tar";
    };
    version = "0.22.2";
  };
  http_signatures = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "4e4b501a936dbf4cb5222597038a89ea10781776770d2e185849fa829686b34c";
      url = "https://repo.hex.pm/tarballs/http_signatures-0.1.0.tar";
    };
    version = "0.1.0";
  };
  mox = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "55a0a5ba9ccc671518d068c8dddd20eeb436909ea79d1799e2209df7eaa98b6c";
      url = "https://repo.hex.pm/tarballs/mox-0.5.2.tar";
    };
    version = "0.5.2";
  };
  jose = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "16d8e460dae7203c6d1efa3f277e25b5af8b659febfc2f2eb4bacf87f128b80a";
      url = "https://repo.hex.pm/tarballs/jose-1.10.1.tar";
    };
    version = "1.10.1";
  };
  unicode_util_compat = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "d869e4c68901dd9531385bb0c8c40444ebf624e60b6962d95952775cac5e90cd";
      url = "https://repo.hex.pm/tarballs/unicode_util_compat-0.4.1.tar";
    };
    version = "0.4.1";
  };
  earmark = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "364ca2e9710f6bff494117dbbd53880d84bebb692dafc3a78eb50aa3183f2bfd";
      url = "https://repo.hex.pm/tarballs/earmark-1.4.3.tar";
    };
    version = "1.4.3";
  };
  deep_merge = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "b4aa1a0d1acac393bdf38b2291af38cb1d4a52806cf7a4906f718e1feb5ee961";
      url = "https://repo.hex.pm/tarballs/deep_merge-1.0.0.tar";
    };
    version = "1.0.0";
  };
  elixir_make = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "8faa29a5597faba999aeeb72bbb9c91694ef8068f0131192fb199f98d32994ef";
      url = "https://repo.hex.pm/tarballs/elixir_make-0.6.1.tar";
    };
    version = "0.6.1";
  };
  db_connection = {
    buildTool = "mix";
    deps = [
      "connection"
    ];
    fetchHex = {
      sha256 = "3bbca41b199e1598245b716248964926303b5d4609ff065125ce98bcd368939e";
      url = "https://repo.hex.pm/tarballs/db_connection-2.2.2.tar";
    };
    version = "2.2.2";
  };
  nimble_parsec = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "32111b3bf39137144abd7ba1cce0914533b2d16ef35e8abc5ec8be6122944263";
      url = "https://repo.hex.pm/tarballs/nimble_parsec-0.6.0.tar";
    };
    version = "0.6.0";
  };
  ex_syslogger = {
    buildTool = "mix";
    deps = [
      "poison"
      "syslog"
    ];
    fetchHex = {
      sha256 = "72b6aa2d47a236e999171f2e1ec18698740f40af0bd02c8c650bf5f1fd1bac79";
      url = "https://repo.hex.pm/tarballs/ex_syslogger-1.5.2.tar";
    };
    version = "1.5.2";
  };
  gun = {
    buildTool = "mix";
    fetchGit = {
      rev = "921c47146b2d9567eac7e9a4d2ccc60fffd4f327";
      url = "https://github.com/ninenines/gun.git";
    };
    version = "921c47146b2d9567eac7e9a4d2ccc60fffd4f327";
  };
  credo = {
    buildTool = "mix";
    deps = [
      "bunt"
      "jason"
    ];
    fetchHex = {
      sha256 = "16392f1edd2cdb1de9fe4004f5ab0ae612c92e230433968eab00aafd976282fc";
      url = "https://repo.hex.pm/tarballs/credo-1.4.1.tar";
    };
    version = "1.4.1";
  };
  ex_const = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "d06e540c9d834865b012a17407761455efa71d0ce91e5831e86881b9c9d82448";
      url = "https://repo.hex.pm/tarballs/ex_const-0.2.4.tar";
    };
    version = "0.2.4";
  };
  ueberauth = {
    buildTool = "mix";
    deps = [
      "plug"
    ];
    fetchHex = {
      sha256 = "d42ace28b870e8072cf30e32e385579c57b9cc96ec74fa1f30f30da9c14f3cc0";
      url = "https://repo.hex.pm/tarballs/ueberauth-0.6.3.tar";
    };
    version = "0.6.3";
  };
  plug_cowboy = {
    buildTool = "mix";
    deps = [
      "cowboy"
      "cowboy_telemetry"
      "plug"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "e936ef151751f386804c51f87f7300f5aaae6893cdad726559c3930c6c032948";
      url = "https://repo.hex.pm/tarballs/plug_cowboy-2.4.0.tar";
    };
    version = "2.4.0";
  };
  phoenix = {
    buildTool = "mix";
    deps = [
      "jason"
      "phoenix_html"
      "phoenix_pubsub"
      "plug"
      "plug_cowboy"
      "plug_crypto"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "8298cdb4e0f943242ba8410780a6a69cbbe972fef199b341a36898dd751bdd66";
      url = "https://repo.hex.pm/tarballs/phoenix-1.5.6.tar";
    };
    version = "1.5.6";
  };
  recon = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "430ffa60685ac1efdfb1fe4c97b8767c92d0d92e6e7c3e8621559ba77598678a";
      url = "https://repo.hex.pm/tarballs/recon-2.5.1.tar";
    };
    version = "2.5.1";
  };
  custom_base = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "4a832a42ea0552299d81652aa0b1f775d462175293e99dfbe4d7dbaab785a706";
      url = "https://repo.hex.pm/tarballs/custom_base-0.2.1.tar";
    };
    version = "0.2.1";
  };
  plug_static_index_html = {
    buildTool = "mix";
    deps = [
      "plug"
    ];
    fetchHex = {
      sha256 = "840123d4d3975585133485ea86af73cb2600afd7f2a976f9f5fd8b3808e636a0";
      url = "https://repo.hex.pm/tarballs/plug_static_index_html-1.0.0.tar";
    };
    version = "1.0.0";
  };
  eternal = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "d5b6b2499ba876c57be2581b5b999ee9bdf861c647401066d3eeed111d096bc4";
      url = "https://repo.hex.pm/tarballs/eternal-1.2.1.tar";
    };
    version = "1.2.1";
  };
  esshd = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "d4dd4c46698093a40a56afecce8a46e246eb35463c457c246dacba2e056f31b5";
      url = "https://repo.hex.pm/tarballs/esshd-0.1.1.tar";
    };
    version = "0.1.1";
  };
  open_api_spex = {
    buildTool = "mix";
    fetchGit = {
      rev = "f296ac0924ba3cf79c7a588c4c252889df4c2edd";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/open_api_spex.git";
    };
    version = "f296ac0924ba3cf79c7a588c4c252889df4c2edd";
  };
  bbcode = {
    buildTool = "mix";
    fetchGit = {
      rev = "f2d267675e9a7e1ad1ea9beb4cc23382762b66c2";
      url = "https://git.pleroma.social/pleroma/elixir-libraries/bbcode.git";
    };
    version = "f2d267675e9a7e1ad1ea9beb4cc23382762b66c2";
  };
  decimal = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "a78296e617b0f5dd4c6caf57c714431347912ffb1d0842e998e9792b5642d697";
      url = "https://repo.hex.pm/tarballs/decimal-2.0.0.tar";
    };
    version = "2.0.0";
  };
  p1_utils = {
    buildTool = "rebar3";
    fetchHex = {
      sha256 = "3fe224de5b2e190d730a3c5da9d6e8540c96484cf4b4692921d1e28f0c32b01c";
      url = "https://repo.hex.pm/tarballs/p1_utils-1.0.18.tar";
    };
    version = "1.0.18";
  };
  plug = {
    buildTool = "mix";
    deps = [
      "mime"
      "plug_crypto"
      "telemetry"
    ];
    fetchHex = {
      sha256 = "41eba7d1a2d671faaf531fa867645bd5a3dce0957d8e2a3f398ccff7d2ef017f";
      url = "https://repo.hex.pm/tarballs/plug-1.10.4.tar";
    };
    version = "1.10.4";
  };
  ex2ms = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "19e27f9212be9a96093fed8cdfbef0a2b56c21237196d26760f11dfcfae58e97";
      url = "https://repo.hex.pm/tarballs/ex2ms-1.5.0.tar";
    };
    version = "1.5.0";
  };
  combine = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "eff8224eeb56498a2af13011d142c5e7997a80c8f5b97c499f84c841032e429f";
      url = "https://repo.hex.pm/tarballs/combine-0.10.0.tar";
    };
    version = "0.10.0";
  };
  phoenix_ecto = {
    buildTool = "mix";
    deps = [
      "ecto"
      "phoenix_html"
      "plug"
    ];
    fetchHex = {
      sha256 = "13f124cf0a3ce0f1948cf24654c7b9f2347169ff75c1123f44674afee6af3b03";
      url = "https://repo.hex.pm/tarballs/phoenix_ecto-4.2.1.tar";
    };
    version = "4.2.1";
  };
  joken = {
    buildTool = "mix";
    deps = [
      "jose"
    ];
    fetchHex = {
      sha256 = "2daa1b12be05184aff7b5ace1d43ca1f81345962285fff3f88db74927c954d3a";
      url = "https://repo.hex.pm/tarballs/joken-2.2.0.tar";
    };
    version = "2.2.0";
  };
  gen_stage = {
    buildTool = "mix";
    fetchHex = {
      sha256 = "d0c66f1c87faa301c1a85a809a3ee9097a4264b2edf7644bf5c123237ef732bf";
      url = "https://repo.hex.pm/tarballs/gen_stage-0.14.3.tar";
    };
    version = "0.14.3";
  };
  base64url = {
    buildTool = "rebar";
    fetchHex = {
      sha256 = "36a90125f5948e3afd7be97662a1504b934dd5dac78451ca6e9abf85a10286be";
      url = "https://repo.hex.pm/tarballs/base64url-0.0.1.tar";
    };
    version = "0.0.1";
  };
}

