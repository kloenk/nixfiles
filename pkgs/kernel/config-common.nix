{ lib, flattenKConf, }:

with lib.kernel;

let
  options = {
    general = {
      SCHED_CORE = yes;

      PSI = yes;

      CGROUPS = yes;
      MEMCG = yes;
      CGROUP_BPF = yes;

      USER_NS = yes;

      FHANDLE = yes;

      EPOLL = yes;
      SIGNALFD = yes;
      TIMERFD = yes;

      BLK_DEV_INITRD = yes;

      EXPERT = yes;

      SECCOMP = yes;
      LTO_CLANG_THIN = option yes;

      BINFMT_ELF = yes;

      KERNEL_ZSTD = yes;
    };
    BPF = {
      BPF = yes;
      BPF_SYSCALL = yes;
      BPF_JIT = yes;
      BPF_JIT_DEFAULT_ON = yes;
      BPF_UNPRIV_DEFAULT_OFF = yes;
      BPF_LSM = yes;
    };
    timer = {
      NO_HZ_FULL = yes; # if you are a distro say Y
    };
    modules = {
      MODULE_COMPRESS = option yes;
      MODULE_COMPRESS_ZSTD = option yes;
      MODPROBE_PATH = option (freeform "/run/current-system/sw/bin/modprobe");
      TRIM_UNUSED_KSYMS = option yes;

      MODULE_ALLOW_BTF_MISMATCH = option yes;
    };
    NET = {
      NET = yes;
      ##
      ## Networking options
      ##
      PACKET_DIAG = module;
      UNIX = yes;
      TLS = module;
      TLS_DEVICE = yes;
      INET_DIAG = module;
      INET_UDP_DIAG = module;
      INET_RAW_DIAG = module;

      ##
      ## Classification
      ##
      VSOCKETS = module;
      VIRTIO_VSOCKETS = module;
      NETLINK_DIAG = module;

      ## end of Networking optios
    };
    NFTables = {
      NETFILTER = yes;
      NETFILTER_ADVANCED = yes;
      BRIDGE_NETFILTER = module;

      ##
      ## Core Netfilter Configuration
      ##

      NETFILTER_INGRESS = yes;
      NETFILTER_EGRESS = yes;
      NETFILTER_SKIP_EGRESS = yes;
      NETFILTER_NETLINK = module;
      NETFILTER_FAMILY_BRIDGE = yes;
      NETFILTER_FAMILY_ARP = yes;
      NETFILTER_BPF_LINK = yes;
      NETFILTER_NETLINK_HOOK = module;
      NETFILTER_NETLINK_ACCT = module;
      NETFILTER_NETLINK_QUEUE = module;
      NETFILTER_NETLINK_LOG = module;
      NETFILTER_NETLINK_OSF = module;
      NF_CONNTRACK = module;
      NF_LOG_SYSLOG = module;
      NETFILTER_CONNCOUNT = module;
      NF_CONNTRACK_MARK = yes;
      NF_CONNTRACK_SECMARK = yes;
      NF_CONNTRACK_ZONES = yes;
      NF_CONNTRACK_PROCFS = yes;
      NF_CONNTRACK_EVENTS = yes;
      NF_CONNTRACK_TIMEOUT = yes;
      NF_CONNTRACK_TIMESTAMP = yes;
      NF_CONNTRACK_LABELS = yes;
      NF_CT_PROTO_DCCP = yes;
      NF_CT_PROTO_GRE = yes;
      NF_CT_PROTO_SCTP = yes;
      NF_CT_PROTO_UDPLITE = yes;
      NF_CONNTRACK_AMANDA = module;
      NF_CONNTRACK_FTP = module;
      NF_CONNTRACK_H323 = module;
      NF_CONNTRACK_IRC = module;
      NF_CONNTRACK_BROADCAST = module;
      NF_CONNTRACK_NETBIOS_NS = module;
      NF_CONNTRACK_SNMP = module;
      NF_CONNTRACK_PPTP = module;
      NF_CONNTRACK_SANE = module;
      NF_CONNTRACK_SIP = module;
      NF_CONNTRACK_TFTP = module;
      NF_CT_NETLINK = module;
      NF_CT_NETLINK_TIMEOUT = module;
      NF_CT_NETLINK_HELPER = module;
      NETFILTER_NETLINK_GLUE_CT = yes;
      NF_NAT = module;
      NF_NAT_AMANDA = module;
      NF_NAT_FTP = module;
      NF_NAT_IRC = module;
      NF_NAT_SIP = module;
      NF_NAT_TFTP = module;
      NF_NAT_REDIRECT = yes;
      NF_NAT_MASQUERADE = yes;
      NETFILTER_SYNPROXY = module;
      NF_TABLES = module;
      NF_TABLES_INET = yes;
      NF_TABLES_NETDEV = yes;
      NFT_NUMGEN = module;
      NFT_CT = module;
      NFT_FLOW_OFFLOAD = module;
      NFT_CONNLIMIT = module;
      NFT_LOG = module;
      NFT_LIMIT = module;
      NFT_MASQ = module;
      NFT_REDIR = module;
      NFT_NAT = module;
      NFT_TUNNEL = module;
      NFT_QUEUE = module;
      NFT_QUOTA = module;
      NFT_REJECT = module;
      NFT_REJECT_INET = module;
      NFT_COMPAT = module;
      NFT_HASH = module;
      NFT_FIB = module;
      NFT_FIB_INET = module;
      NFT_XFRM = module;
      NFT_SOCKET = module;
      NFT_OSF = module;
      NFT_TPROXY = module;
      NFT_SYNPROXY = module;
      NF_DUP_NETDEV = module;
      NFT_DUP_NETDEV = module;
      NFT_FWD_NETDEV = module;
      NFT_FIB_NETDEV = module;
      NFT_REJECT_NETDEV = module;
      NF_FLOW_TABLE_INET = module;
      NF_FLOW_TABLE = module;
      NF_FLOW_TABLE_PROCFS = yes;
      #NETFILTER_XTABLES = yes;

      ##
      ## Xtables combined modules
      ##
      #NETFILTER_XT_MARK = module;
      #NETFILTER_XT_CONNMARK = module;

      ##
      ## Xtables targets
      ##

      NETFILTER_XT_TARGET_AUDIT = module;
      NETFILTER_XT_TARGET_CHECKSUM = module;
      NETFILTER_XT_TARGET_CLASSIFY = module;
      NETFILTER_XT_TARGET_CONNMARK = module;
      NETFILTER_XT_TARGET_CONNSECMARK = module;
      NETFILTER_XT_TARGET_CT = module;
      NETFILTER_XT_TARGET_DSCP = module;
      NETFILTER_XT_TARGET_HL = module;
      NETFILTER_XT_TARGET_HMARK = module;
      NETFILTER_XT_TARGET_IDLETIMER = module;
      NETFILTER_XT_TARGET_LED = option module;
      NETFILTER_XT_TARGET_LOG = module;
      NETFILTER_XT_TARGET_MARK = module;
      NETFILTER_XT_NAT = module;
      NETFILTER_XT_TARGET_NETMAP = module;
      NETFILTER_XT_TARGET_NFLOG = module;
      NETFILTER_XT_TARGET_NFQUEUE = module;
      NETFILTER_XT_TARGET_NOTRACK = module; # ??
      NETFILTER_XT_TARGET_RATEEST = module;
      NETFILTER_XT_TARGET_REDIRECT = module;
      NETFILTER_XT_TARGET_MASQUERADE = module;
      NETFILTER_XT_TARGET_TEE = module;
      NETFILTER_XT_TARGET_TPROXY = module;
      NETFILTER_XT_TARGET_TRACE = module;
      NETFILTER_XT_TARGET_SECMARK = module;
      NETFILTER_XT_TARGET_TCPMSS = module;
      NETFILTER_XT_TARGET_TCPOPTSTRIP = module;

      ##
      ## Xtables matches
      ##

      NETFILTER_XT_MATCH_ADDRTYPE = module;
      NETFILTER_XT_MATCH_BPF = module;
      NETFILTER_XT_MATCH_CGROUP = module;
      NETFILTER_XT_MATCH_CLUSTER = module;
      NETFILTER_XT_MATCH_COMMENT = module;
      NETFILTER_XT_MATCH_CONNBYTES = module;
      NETFILTER_XT_MATCH_CONNLABEL = module;
      NETFILTER_XT_MATCH_CONNLIMIT = module;
      NETFILTER_XT_MATCH_CONNMARK = module;
      NETFILTER_XT_MATCH_CONNTRACK = module;
      NETFILTER_XT_MATCH_CPU = module;
      NETFILTER_XT_MATCH_DCCP = module;
      NETFILTER_XT_MATCH_DEVGROUP = module;
      NETFILTER_XT_MATCH_DSCP = module;
      NETFILTER_XT_MATCH_ECN = module;
      NETFILTER_XT_MATCH_ESP = module;
      NETFILTER_XT_MATCH_HASHLIMIT = module;
      NETFILTER_XT_MATCH_HELPER = module;
      NETFILTER_XT_MATCH_HL = module;
      NETFILTER_XT_MATCH_IPCOMP = module;
      NETFILTER_XT_MATCH_IPRANGE = module;
      #NETFILTER_XT_MATCH_IPVS = module; # ??
      NETFILTER_XT_MATCH_L2TP = module;
      NETFILTER_XT_MATCH_LENGTH = module;
      NETFILTER_XT_MATCH_LIMIT = module;
      NETFILTER_XT_MATCH_MAC = module;
      NETFILTER_XT_MATCH_MARK = module;
      NETFILTER_XT_MATCH_MULTIPORT = module;
      NETFILTER_XT_MATCH_NFACCT = module;
      NETFILTER_XT_MATCH_OSF = module;
      NETFILTER_XT_MATCH_OWNER = module;
      NETFILTER_XT_MATCH_POLICY = module;
      NETFILTER_XT_MATCH_PHYSDEV = module;
      NETFILTER_XT_MATCH_PKTTYPE = module;
      NETFILTER_XT_MATCH_QUOTA = module;
      NETFILTER_XT_MATCH_RATEEST = module;
      NETFILTER_XT_MATCH_REALM = module;
      NETFILTER_XT_MATCH_RECENT = module;
      NETFILTER_XT_MATCH_SCTP = module;
      NETFILTER_XT_MATCH_SOCKET = module;
      NETFILTER_XT_MATCH_STATE = module;
      NETFILTER_XT_MATCH_STATISTIC = module;
      NETFILTER_XT_MATCH_STRING = module;
      NETFILTER_XT_MATCH_TCPMSS = module;
      NETFILTER_XT_MATCH_TIME = module;
      NETFILTER_XT_MATCH_U32 = module;

      ## End of Core Netfilter Configuration

      ##
      ## IP: Netfilter Configuration
      NF_TABLES_ARP = yes;
      NFT_DUP_IPV4 = module;
      NFT_FIB_IPV4 = module;
      IP_NF_RAW = module;
      IP_NF_SECURITY = module;
      ## end of IP: Netfilter Configuration

      ##
      ## IPv6: Netfilter Configuration
      ##
      NFT_FIB_IPV6 = option module;
      IP6_NF_RAW = module;
      IP6_NF_SECURITY = module;
      ## end of IPv6: Netfilter Configuration

      NF_TABLES_BRIDGE = module;
      NFT_BRIDGE_META = module;
      NFT_BRIDGE_REJECT = module;
      NF_CONNTRACK_BRIDGE = module;
      BRIDGE_NF_EBTABLES = module;
      BRIDGE_EBT_BROUTE = module;
      BRIDGE_EBT_T_FILTER = module;
      BRIDGE_EBT_T_NAT = module;
      BRIDGE_EBT_802_3 = module;
      BRIDGE_EBT_AMONG = module;
      BRIDGE_EBT_ARP = module;
      BRIDGE_EBT_IP = module;
      BRIDGE_EBT_IP6 = module;
      BRIDGE_EBT_LIMIT = module;
      BRIDGE_EBT_MARK = module;
      BRIDGE_EBT_PKTTYPE = module;
      BRIDGE_EBT_STP = module;
      BRIDGE_EBT_VLAN = module;
      BRIDGE_EBT_ARPREPLY = module;
      BRIDGE_EBT_DNAT = module;
      BRIDGE_EBT_MARK_T = module;
      BRIDGE_EBT_REDIRECT = module;
      BRIDGE_EBT_SNAT = module;
      BRIDGE_EBT_LOG = module;
      BRIDGE_EBT_NFLOG = module;

      BRIDGE = lib.mkDefault module;
      BRIDGE_VLAN_FILTERING = option yes;
    };
    DMI = {
      DMIID = yes;
      DMI_SYSFS = yes;
    };

    NVME = {
      NVME_CORE = module;
      BLK_DEV_NVME = module;
    };

    DeviceMapper = {
      MD = yes;
      BLK_DEV_MD = yes;

      BLK_DEV_DM = lib.mkDefault module;

      DM_CRYPT = lib.mkDefault module;
      DM_VERITY = lib.mkDefault module;

      DAX = lib.mkDefault yes;
      NVMEM = yes;
      NVME_HWMON = yes;
    };

    DEVICES = {
      NULL_TTY = module;
      HW_RANDOM = lib.mkDefault module;
    };

    WATCHDOG = {
      WATCHDOG_CORE = lib.mkDefault module;
      WATCHDOG_NOWAYOUT = option yes;
      WATCHDOG_SYSFS = option yes;
    };

    FileSystems = {
      DEVTMPFS = yes;
      DEVTMPFS_SAFE = yes;

      INOTIFY_USER = yes;

      AUTOFS_FS = module;
      FUSE_FS = lib.mkDefault module;
      OVERLAY_FS = module;

      ##
      ## Pseudo filesystems
      ##
      PROC_FS = yes;
      SYSFS = yes;
      TMPFS = yes;
      TMPFS_POSIX_ACL = yes;
      TMPFS_XATTR = yes;
      CONFIGFS_FS = yes;
      ## end of Pseudo filesystems

      EROFS_FS = module;
    };

    MMC = {
      MMC = module;
      MMC_SDHCI = module;
      MMC_SDHCI_PCI = module;
    };

    security = {
      TRUSTED_KEYS = yes;
      ENCRYPTED_KEYS = yes;
      FORTIFY_SOURCE = yes;
    };

    crypto = {
      CRYPTO = yes;

      ##
      ## Crypto core or helper
      ##
      CRYPTO_HMAC = yes;

      CRYPTO_CRYPTD = module;
      ## end of Crypto core or helper

      ##
      ## Public-key cryptography
      ##
      CRYPTO_RSA = option yes;
      CRYPTO_DH = option module;
      CRYPTO_ECC = option module;
      CRYPTO_ECDH = option module;
      CRYPTO_ECDSA = option module;
      CRYPTO_CURVE25519 = option module;
      ## end of Public-key cryptography

      ##
      ## Block ciphers
      ##
      CRYPTO_AES = yes;
      ## end of Block ciphers

      ##
      ## Hashes, digests, and MACs
      ##
      CRYPTO_SHA256 = yes;
      ## end of Hashes, digests, and MACs

      ##
      ## Userspace interface
      ##
      CRYPTO_USER_API = yes;
      CRYPTO_USER_API_HASH = yes;
      CRYPTO_USER_API_RNG = yes;
      ## end of Userspace interface

      ##
      ## Accelerated Cryptographic Algorithms for CPU (x86)
      ##
      CRYPTO_CURVE25519_X86 = option module;
      CRYPTO_AES_NI_INTEL = option module;
      CRYPTO_BLOWFISH_X86_64 = option module;
      CRYPTO_CAMELLIA_X86_64 = option module;
      CRYPTO_CAMELLIA_AESNI_AVX_X86_64 = option module;
      CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 = option module;
      CRYPTO_CAST5_AVX_X86_64 = option module;
      CRYPTO_CAST6_AVX_X86_64 = option module;
      CRYPTO_DES3_EDE_X86_64 = option module;
      CRYPTO_SERPENT_SSE2_X86_64 = option module;
      CRYPTO_SERPENT_AVX_X86_64 = option module;
      CRYPTO_SERPENT_AVX2_X86_64 = option module;
      CRYPTO_SM4_AESNI_AVX_X86_64 = option module;
      CRYPTO_SM4_AESNI_AVX2_X86_64 = option module;
      CRYPTO_TWOFISH_X86_64 = option module;
      CRYPTO_TWOFISH_X86_64_3WAY = option module;
      CRYPTO_TWOFISH_AVX_X86_64 = option module;
      CRYPTO_ARIA_AESNI_AVX_X86_64 = option module;
      CRYPTO_ARIA_AESNI_AVX2_X86_64 = option module;
      CRYPTO_ARIA_GFNI_AVX512_X86_64 = option module;
      CRYPTO_CHACHA20_X86_64 = option module;
      CRYPTO_AEGIS128_AESNI_SSE2 = option module;
      CRYPTO_NHPOLY1305_SSE2 = option module;
      CRYPTO_NHPOLY1305_AVX2 = option module;
      CRYPTO_BLAKE2S_X86 = option module;
      CRYPTO_POLYVAL_CLMUL_NI = option module;
      CRYPTO_POLY1305_X86_64 = option module;
      CRYPTO_SHA1_SSSE3 = option module;
      CRYPTO_SHA256_SSSE3 = option module;
      CRYPTO_SHA512_SSSE3 = option module;
      CRYPTO_SM3_AVX_X86_64 = option module;
      CRYPTO_GHASH_CLMUL_NI_INTEL = option module;
      CRYPTO_CRC32C_INTEL = option module;
      CRYPTO_CRC32_PCLMUL = option module;
      ## end of Accelerated Cryptographic Algorithms for CPU (x86)
    };
  };
in flattenKConf options
