#!/bin/bash

# Pink H34 H35
fvctl -f pwd add-flowspace Pink_E12_H34_H35 000000000000020c 3 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.35 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H35_H34 000000000000020c 3 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.34 Pink=7

# Pink H34 H36
fvctl -f pwd add-flowspace Pink_E12_H34_H36 000000000000020c 3 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H36_H34 000000000000020c 3 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.34 Pink=7

# Pink H35 H36
fvctl -f pwd add-flowspace Pink_E12_H35_H36 000000000000020c 3 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H36_H35 000000000000020c 3 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.35 Pink=7

# Pink H34 H45
fvctl -f pwd add-flowspace Pink_E12_H34_H45 000000000000020c 3 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H45_H34 000000000000020c 3 in_port=6,nw_src=10.0.0.45,nw_dst=10.0.0.34 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H34_H45 000000000000010c 3 in_port=3,nw_src=10.0.0.34,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H45_H34 000000000000010c 3 in_port=4,nw_src=10.0.0.45,nw_dst=10.0.0.34 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H34_H45  0000000000000007 3 in_port=4,nw_src=10.0.0.34,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H45_H34  0000000000000007 3 in_port=5,nw_src=10.0.0.45,nw_dst=10.0.0.34 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H34_H45 000000000000010f 3 in_port=4,nw_src=10.0.0.34,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H45_H34 000000000000010f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.34 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H34_H45 000000000000020f 3 in_port=6,nw_src=10.0.0.34,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H45_H34 000000000000020f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.34 Pink=7

# Pink H35 H45
fvctl -f pwd add-flowspace Pink_E12_H35_H45 000000000000020c 3 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H45_H35 000000000000020c 3 in_port=6,nw_src=10.0.0.45,nw_dst=10.0.0.35 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H35_H45 000000000000010c 3 in_port=3,nw_src=10.0.0.35,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H45_H35 000000000000010c 3 in_port=4,nw_src=10.0.0.45,nw_dst=10.0.0.35 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H35_H45  0000000000000007 3 in_port=4,nw_src=10.0.0.35,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H45_H35  0000000000000007 3 in_port=5,nw_src=10.0.0.45,nw_dst=10.0.0.35 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H35_H45 000000000000010f 3 in_port=4,nw_src=10.0.0.35,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H45_H35 000000000000010f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.35 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H35_H45 000000000000020f 3 in_port=6,nw_src=10.0.0.35,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H45_H35 000000000000020f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.35 Pink=7

# Pink H36 H45
fvctl -f pwd add-flowspace Pink_E12_H36_H45 000000000000020c 3 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E12_H45_H36 000000000000020c 3 in_port=6,nw_src=10.0.0.45,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H36_H45 000000000000010c 3 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A12_H45_H36 000000000000010c 3 in_port=4,nw_src=10.0.0.45,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H36_H45  0000000000000007 3 in_port=4,nw_src=10.0.0.36,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_C7_H45_H36  0000000000000007 3 in_port=5,nw_src=10.0.0.45,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H36_H45 000000000000010f 3 in_port=4,nw_src=10.0.0.36,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_A15_H45_H36 000000000000010f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.36 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H36_H45 000000000000020f 3 in_port=6,nw_src=10.0.0.36,nw_dst=10.0.0.45 Pink=7
fvctl -f pwd add-flowspace Pink_E15_H45_H36 000000000000020f 3 in_port=3,nw_src=10.0.0.45,nw_dst=10.0.0.36 Pink=7

