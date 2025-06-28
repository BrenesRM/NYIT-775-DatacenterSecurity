#!/bin/bash

# Blue Slice for h31–h36
# Switches: E11 (dpid=20b), E12 (dpid=20c), A11 (dpid=10b), A12 (dpid=10c)
# Slice: Blue=7
# Controller port: 6000

# Host IPs: 10.0.0.31 – 10.0.0.36

# === E11 intra-switch (h31–h33) ===
fvctl -f pwd add-flowspace Blue_E11_h31_h32 000000000000020b 2 in_port=1,nw_src=10.0.0.31,nw_dst=10.0.0.32 Blue=7
fvctl -f pwd add-flowspace Blue_E11_h32_h31 000000000000020b 2 in_port=2,nw_src=10.0.0.32,nw_dst=10.0.0.31 Blue=7

fvctl -f pwd add-flowspace Blue_E11_h31_h33 000000000000020b 2 in_port=1,nw_src=10.0.0.31,nw_dst=10.0.0.33 Blue=7
fvctl -f pwd add-flowspace Blue_E11_h33_h31 000000000000020b 2 in_port=3,nw_src=10.0.0.33,nw_dst=10.0.0.31 Blue=7

fvctl -f pwd add-flowspace Blue_E11_h32_h33 000000000000020b 2 in_port=2,nw_src=10.0.0.32,nw_dst=10.0.0.33 Blue=7
fvctl -f pwd add-flowspace Blue_E11_h33_h32 000000000000020b 2 in_port=3,nw_src=10.0.0.33,nw_dst=10.0.0.32 Blue=7

# === E12 intra-switch (h34–h36) ===
fvctl -f pwd add-flowspace Blue_E12_h34_h35 000000000000020c 2 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.35 Blue=7
fvctl -f pwd add-flowspace Blue_E12_h35_h34 000000000000020c 2 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.34 Blue=7

fvctl -f pwd add-flowspace Blue_E12_h34_h36 000000000000020c 2 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.36 Blue=7
fvctl -f pwd add-flowspace Blue_E12_h36_h34 000000000000020c 2 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.34 Blue=7

fvctl -f pwd add-flowspace Blue_E12_h35_h36 000000000000020c 2 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.36 Blue=7
fvctl -f pwd add-flowspace Blue_E12_h36_h35 000000000000020c 2 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.35 Blue=7

# === E11 → E12 via A11 ===
# h31–h33 to h34–h36
for SRC in 31 32 33; do
  for DST in 34 35 36; do
    PORT=$((SRC - 30)) # port 1–3
    fvctl -f pwd add-flowspace Blue_E11_h${SRC}_h${DST} 000000000000020b 2 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Blue=7
    fvctl -f pwd add-flowspace Blue_E11_h${DST}_h${SRC} 000000000000020b 2 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Blue=7
    fvctl -f pwd add-flowspace Blue_E11_h${DST}_h${SRC} 000000000000020b 2 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Blue=7
  done
done

# === E12 → E11 via A11 ===
# h34–h36 to h31–h33
for SRC in 34 35 36; do
  for DST in 31 32 33; do
    PORT=$((SRC - 33)) # port 1–3
    fvctl -f pwd add-flowspace Blue_E12_h${SRC}_h${DST} 000000000000020c 2 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Blue=7
    fvctl -f pwd add-flowspace Blue_E12_h${DST}_h${SRC} 000000000000020c 2 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Blue=7
    fvctl -f pwd add-flowspace Blue_E12_h${DST}_h${SRC} 000000000000020c 2 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Blue=7
  done
done

# === Aggregation switch flowspace ===
# A11 and A12 forwarding traffic (wildcard match on in_port only)
fvctl -f pwd add-flowspace Blue_A11_forward1 000000000000010b 2 in_port=2 Blue=7
fvctl -f pwd add-flowspace Blue_A11_forward2 000000000000010b 2 in_port=3 Blue=7

fvctl -f pwd add-flowspace Blue_A12_forward1 000000000000010c 2 in_port=2 Blue=7
fvctl -f pwd add-flowspace Blue_A12_forward2 000000000000010c 2 in_port=3 Blue=7
