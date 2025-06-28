#!/bin/bash

# Red Slice for h8, h9, h11, h12
# Switches involved: E3 (dpid=203), E4 (dpid=204), A2 (dpid=102), A5 (dpid=105), C4 (dpid=004)
# Controller listens on TCP port 4000
# Slice ID: Red=7

# Red H8 H9
fvctl -f pwd add-flowspace Red_E3_h8_h9 0000000000000203 1 in_port=2,nw_src=10.0.0.8,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_E3_h9_h8 0000000000000203 1 in_port=3,nw_src=10.0.0.9,nw_dst=10.0.0.8 Red=7

# Red H10 H11
fvctl -f pwd add-flowspace Red_E4_h11_h12 0000000000000204 1 in_port=2,nw_src=10.0.0.11,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_E4_h12_h11 0000000000000204 1 in_port=3,nw_src=10.0.0.12,nw_dst=10.0.0.11 Red=7

# Red H8 H11
fvctl -f pwd add-flowspace Red_E3_h8_h11 0000000000000203 1 in_port=2,nw_src=10.0.0.8,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_E3_h11_h8 0000000000000203 1 in_port=5,nw_src=10.0.0.11,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A2_h8_h11 0000000000000102 1 in_port=3,nw_src=10.0.0.8,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A2_h11_h8 0000000000000102 1 in_port=4,nw_src=10.0.0.11,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_C4_h8_h11 0000000000000004 1 in_port=1,nw_src=10.0.0.8,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_C4_h11_h8 0000000000000004 1 in_port=2,nw_src=10.0.0.11,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A5_h8_h11 0000000000000105 1 in_port=4,nw_src=10.0.0.8,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A5_h11_h8 0000000000000105 1 in_port=1,nw_src=10.0.0.11,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_E4_h8_h11 0000000000000204 1 in_port=5,nw_src=10.0.0.8,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_E4_h11_h8 0000000000000204 1 in_port=2,nw_src=10.0.0.11,nw_dst=10.0.0.8 Red=7

# Red H8 H12
fvctl -f pwd add-flowspace Red_E3_h8_h12 0000000000000203 1 in_port=2,nw_src=10.0.0.8,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_E3_h12_h8 0000000000000203 1 in_port=5,nw_src=10.0.0.12,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A2_h8_h12 0000000000000102 1 in_port=3,nw_src=10.0.0.8,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_A2_h12_h8 0000000000000102 1 in_port=4,nw_src=10.0.0.12,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_C4_h8_h12 0000000000000004 1 in_port=1,nw_src=10.0.0.8,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_C4_h12_h8 0000000000000004 1 in_port=2,nw_src=10.0.0.12,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A5_h8_h12 0000000000000105 1 in_port=4,nw_src=10.0.0.8,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_A5_h12_h8 0000000000000105 1 in_port=1,nw_src=10.0.0.12,nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_E4_h8_h12 0000000000000204 1 in_port=5,nw_src=10.0.0.8,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_E4_h12_h8 0000000000000204 1 in_port=3,nw_src=10.0.0.12,nw_dst=10.0.0.8 Red=7

# Red H9 H11
fvctl -f pwd add-flowspace Red_E3_h9_h11 0000000000000203 1 in_port=3,nw_src=10.0.0.9,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_E3_h11_h9 0000000000000203 1 in_port=5,nw_src=10.0.0.11,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_A2_h9_h11 0000000000000102 1 in_port=3,nw_src=10.0.0.9,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A2_h11_h9 0000000000000102 1 in_port=4,nw_src=10.0.0.11,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_C4_h9_h11 0000000000000004 1 in_port=1,nw_src=10.0.0.9,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_C4_h11_h9 0000000000000004 1 in_port=2,nw_src=10.0.0.11,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_A5_h9_h11 0000000000000105 1 in_port=4,nw_src=10.0.0.9,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A5_h11_h9 0000000000000105 1 in_port=1,nw_src=10.0.0.11,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_E4_h9_h11 0000000000000204 1 in_port=5,nw_src=10.0.0.9,nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_E4_h11_h9 0000000000000204 1 in_port=2,nw_src=10.0.0.11,nw_dst=10.0.0.9 Red=7

# Red H9 H12
fvctl -f pwd add-flowspace Red_E3_h9_h12 0000000000000203 1 in_port=3,nw_src=10.0.0.9,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_E3_h12_h9 0000000000000203 1 in_port=5,nw_src=10.0.0.12,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_A2_h9_h12 0000000000000102 1 in_port=3,nw_src=10.0.0.9,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_A2_h12_h9 0000000000000102 1 in_port=4,nw_src=10.0.0.12,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_C4_h9_h12 0000000000000004 1 in_port=1,nw_src=10.0.0.9,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_C4_h12_h9 0000000000000004 1 in_port=2,nw_src=10.0.0.12,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_A5_h9_h12 0000000000000105 1 in_port=4,nw_src=10.0.0.9,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_A5_h12_h9 0000000000000105 1 in_port=1,nw_src=10.0.0.12,nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_E4_h9_h12 0000000000000204 1 in_port=5,nw_src=10.0.0.9,nw_dst=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_E4_h12_h9 0000000000000204 1 in_port=3,nw_src=10.0.0.12,nw_dst=10.0.0.9 Red=7