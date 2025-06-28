#!/bin/bash

# Green Slice for h28–h33
# Switches: E10 (dpid=20a), E11 (dpid=20b), A10 (dpid=10a), A11 (dpid=10b)
# Slice: Green=6
# Controller port: 5000

# Host IPs: 10.0.0.28 – 10.0.0.33

# === E10 intra-switch (h28–h30) ===
fvctl -f pwd add-flowspace Green_E10_h28_h29 000000000000020a 1 in_port=1,nw_src=10.0.0.28,nw_dst=10.0.0.29 Green=7
fvctl -f pwd add-flowspace Green_E10_h29_h28 000000000000020a 1 in_port=2,nw_src=10.0.0.29,nw_dst=10.0.0.28 Green=7

fvctl -f pwd add-flowspace Green_E10_h28_h30 000000000000020a 1 in_port=1,nw_src=10.0.0.28,nw_dst=10.0.0.30 Green=7
fvctl -f pwd add-flowspace Green_E10_h30_h28 000000000000020a 1 in_port=3,nw_src=10.0.0.30,nw_dst=10.0.0.28 Green=7

fvctl -f pwd add-flowspace Green_E10_h29_h30 000000000000020a 1 in_port=2,nw_src=10.0.0.29,nw_dst=10.0.0.30 Green=7
fvctl -f pwd add-flowspace Green_E10_h30_h29 000000000000020a 1 in_port=3,nw_src=10.0.0.30,nw_dst=10.0.0.29 Green=7

# === E11 intra-switch (h31–h33) ===
fvctl -f pwd add-flowspace Green_E11_h31_h32 000000000000020b 1 in_port=1,nw_src=10.0.0.31,nw_dst=10.0.0.32 Green=7
fvctl -f pwd add-flowspace Green_E11_h32_h31 000000000000020b 1 in_port=2,nw_src=10.0.0.32,nw_dst=10.0.0.31 Green=7

fvctl -f pwd add-flowspace Green_E11_h31_h33 000000000000020b 1 in_port=1,nw_src=10.0.0.31,nw_dst=10.0.0.33 Green=7
fvctl -f pwd add-flowspace Green_E11_h33_h31 000000000000020b 1 in_port=3,nw_src=10.0.0.33,nw_dst=10.0.0.31 Green=7

fvctl -f pwd add-flowspace Green_E11_h32_h33 000000000000020b 1 in_port=2,nw_src=10.0.0.32,nw_dst=10.0.0.33 Green=7
fvctl -f pwd add-flowspace Green_E11_h33_h32 000000000000020b 1 in_port=3,nw_src=10.0.0.33,nw_dst=10.0.0.32 Green=7

# === E12 intra-switch (h34–h36) ===
fvctl -f pwd add-flowspace Green_E12_h34_h35 000000000000020c 1 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.35 Green=7
fvctl -f pwd add-flowspace Green_E12_h35_h34 000000000000020c 1 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.34 Green=7

fvctl -f pwd add-flowspace Green_E12_h34_h36 000000000000020c 1 in_port=1,nw_src=10.0.0.34,nw_dst=10.0.0.36 Green=7
fvctl -f pwd add-flowspace Green_E12_h36_h34 000000000000020c 1 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.34 Green=7

fvctl -f pwd add-flowspace Green_E12_h35_h36 000000000000020c 1 in_port=2,nw_src=10.0.0.35,nw_dst=10.0.0.36 Green=7
fvctl -f pwd add-flowspace Green_E12_h36_h35 000000000000020c 1 in_port=3,nw_src=10.0.0.36,nw_dst=10.0.0.35 Green=7


# === E10 <-> E11 ===
for SRC in 28 29 30; do
  for DST in 31 32 33; do
    PORT=$((SRC - 27)) # port 1–3
    fvctl -f pwd add-flowspace Green_E10_h${SRC}_h${DST} 000000000000020a 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

for SRC in 31 32 33; do
  for DST in 28 29 30; do
    PORT=$((SRC - 30)) # port 1–3
    fvctl -f pwd add-flowspace Green_E11_h${SRC}_h${DST} 000000000000020b 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

# === E10 <-> E12 ===
for SRC in 28 29 30; do
  for DST in 34 35 36; do
    PORT=$((SRC - 27)) # port 1–3
    fvctl -f pwd add-flowspace Green_E10_h${SRC}_h${DST} 000000000000020a 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E10_h${DST}_h${SRC} 000000000000020a 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

for SRC in 34 35 36; do
  for DST in 28 29 30; do
    PORT=$((SRC - 33)) # port 1–3
    fvctl -f pwd add-flowspace Green_E12_h${SRC}_h${DST} 000000000000020c 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

# === E11 <-> E12 ===
for SRC in 31 32 33; do
  for DST in 34 35 36; do
    PORT=$((SRC - 30)) # port 1–3
    fvctl -f pwd add-flowspace Green_E11_h${SRC}_h${DST} 000000000000020b 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E11_h${DST}_h${SRC} 000000000000020b 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

for SRC in 34 35 36; do
  for DST in 31 32 33; do
    PORT=$((SRC - 33)) # port 1–3
    fvctl -f pwd add-flowspace Green_E12_h${SRC}_h${DST} 000000000000020c 1 in_port=${PORT},nw_src=10.0.0.${SRC},nw_dst=10.0.0.${DST} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=4,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=5,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
    fvctl -f pwd add-flowspace Green_E12_h${DST}_h${SRC} 000000000000020c 1 in_port=6,nw_src=10.0.0.${DST},nw_dst=10.0.0.${SRC} Green=7
  done
done

# === Aggregation switches ===
fvctl -f pwd add-flowspace Green_A10_forward1 000000000000010a 1 in_port=1 Green=7
fvctl -f pwd add-flowspace Green_A10_forward2 000000000000010a 1 in_port=2 Green=7
fvctl -f pwd add-flowspace Green_A10_forward3 000000000000010a 1 in_port=3 Green=7

fvctl -f pwd add-flowspace Green_A11_forward1 000000000000010b 1 in_port=1 Green=7
fvctl -f pwd add-flowspace Green_A11_forward2 000000000000010b 1 in_port=2 Green=7
fvctl -f pwd add-flowspace Green_A11_forward3 000000000000010b 1 in_port=3 Green=7

fvctl -f pwd add-flowspace Green_A12_forward1 000000000000010c 1 in_port=1 Green=6
fvctl -f pwd add-flowspace Green_A12_forward2 000000000000010c 1 in_port=2 Green=6
fvctl -f pwd add-flowspace Green_A12_forward3 000000000000010c 1 in_port=3 Green=6