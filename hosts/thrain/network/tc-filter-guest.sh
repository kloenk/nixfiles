#!/usr/bin/env bash

# ╰─ sudo tc filter add dev guest parent 2: protocol ip prio 10 u32 match ip sport 443 0xffff flowid 2:11

# dev guest out
#   2:10 -> dns/ssh/push
#   2:11 -> port 0-1024
#   2:12 -> default

# 2:10
## dns
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 17 0xff match ip dport 53 0xff flowid 2:10
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 17 0xff match ip sport 53 0xff flowid 2:10


## ssh
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 06 0xff match ip dport 22 0xff flowid 2:10
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 06 0xff match ip sport 22 0xff flowid 2:10
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 06 0xff match ip dport 62954 0xff flowid 2:10
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 06 0xff match ip sport 62954 0xff flowid 2:10

## apple push
tc filter add dev guest parent 2: protocol ip prio 20 u32 match ip protocol 06 0xff match ip sport 5223 0xff flowid 2:10

# 2:11
tc filter add dev guest parent 2: protocol ip prio 40 u32 match ip sport 0 0xfc00 flowid 2:11
