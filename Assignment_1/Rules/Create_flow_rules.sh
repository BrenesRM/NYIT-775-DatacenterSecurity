#!/bin/bash

# Mininet SDN Flow Configuration Fix Script
# Addresses port mapping issues and adds missing host connectivity

# Define all involved switches
switches=(E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 E11 E12 E13 E14 E15 E16 E17 E18 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16 A17 A18 C1 C2 C3 C4 C5 C6 C7 C8 C9)

echo "[*] Resetting flows and applying base DROP rules..."

for switch in "${switches[@]}"; do
    echo "[+] Clearing flows on $switch"
    sudo ovs-ofctl del-flows "$switch"
    sudo ovs-ofctl add-flow "$switch" "priority=1,actions=drop"
done

echo "[*] Re-enabling ARP flooding on all switches..."

for sw in "${switches[@]}"; do
    sudo ovs-ofctl add-flow "$sw" "priority=100,arp,actions=flood"
    echo "[+] ARP flood rule set on $sw"
done

echo "[Ã¢Å“â€] All switches initialized with base flow rules."

###########################################
# Port Mapping Reference (verify with net):
# E1: E1-eth1:h1-eth0 E1-eth2:h2-eth0 E1-eth3:h3-eth0 E1-eth4:A1-eth1 E1-eth5:A2-eth1 E1-eth6:A3-eth1
# A1: A1 lo:  A1-eth1:E1-eth4 A1-eth2:E2-eth4 A1-eth3:E3-eth4 A1-eth4:C1-eth1 A1-eth5:C2-eth1 A1-eth6:C3-eth1
# E2: E2-eth1:h4-eth0 E2-eth2:h5-eth0 E2-eth3:h6-eth0 E2-eth4:A1-eth2 E2-eth5:A2-eth2 E2-eth6:A3-eth2
###########################################

###########################################
# Green Path 1: h1 (10.0.0.1) <-> h4 (10.0.0.4)
###########################################

echo "[*] Installing h1 <-> h4 flows..."

# E1: Forward h1->h4 to A1, forward h4->h1 to h1
sudo ovs-ofctl add-flow E1 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4" # From h1
sudo ovs-ofctl add-flow E1 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1" # To  A1

# A1: Forward h1->h4 to E2, forward h4->h1 to E1
sudo ovs-ofctl add-flow A1 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2" # From E1
sudo ovs-ofctl add-flow A1 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1" # To E2

# E2: Forward h1->h4 to h4, forward h4->h1 to A1
sudo ovs-ofctl add-flow E2 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1" # From A1
sudo ovs-ofctl add-flow E2 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4" # To h4

echo "Ã¢Å“â€¦ h1 <-> h4 bidirectional rules installed"

##########################################
# Blue Path 2: h3 (10.0.0.3) <-> h4 (10.0.0.4) - Problem with return by over laping rule
##########################################

echo "[*] Installing h3 <-> h4 flows (FIXED)..."

# E1: Forward h3->h4 to A1, forward h4->h3 to h3 (FIXED: was going to h1!)
sudo ovs-ofctl add-flow E1 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:4" # From
sudo ovs-ofctl add-flow E1 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:3" # to

# A1: Forward h3->h4 to E2, forward h4->h3 to E1
sudo ovs-ofctl add-flow A1 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:2" # From
sudo ovs-ofctl add-flow A1 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:1" # To

# E2: Forward h3->h4 to h4 (FIXED: was going to A1!), forward h4->h3 to A1
sudo ovs-ofctl add-flow E2 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:1" # From
sudo ovs-ofctl add-flow E2 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:4" # To

echo "Ã¢Å“â€¦ h3 <-> h4 bidirectional rules installed (CORRECTED)"

##########################################
# Red Path 3: h10 (h10-eth0:10.0.0.10) <-> h22 (h22-eth0:10.0.0.22) 
# h10 h10-eth0:E4-eth1
# E4 lo:  E4-eth1:h10-eth0 E4-eth2:h11-eth0 E4-eth3:h12-eth0 E4-eth4:A4-eth1 E4-eth5:A5-eth1 E4-eth6:A6-eth1
# A5 lo:  A5-eth1:E4-eth5 A5-eth2:E5-eth5 A5-eth3:E6-eth5 A5-eth4:C4-eth2 A5-eth5:C5-eth2 A5-eth6:C6-eth2
# C4 lo:  C4-eth1:A2-eth4 C4-eth2:A5-eth4 C4-eth3:A8-eth4 C4-eth4:A11-eth4 C4-eth5:A14-eth4 C4-eth6:A17-eth4
# A8 lo:  A8-eth1:E7-eth5 A8-eth2:E8-eth5 A8-eth3:E9-eth5 A8-eth4:C4-eth3 A8-eth5:C5-eth3 A8-eth6:C6-eth3
# E8 lo:  E8-eth1:h22-eth0 E8-eth2:h23-eth0 E8-eth3:h24-eth0 E8-eth4:A7-eth2 E8-eth5:A8-eth2 E8-eth6:A9-eth2
# h22 h22-eth0:E8-eth1
##########################################

echo "[*] Installing flows for other hosts (h10 <-> h22)"

# Assuming h10 is at 10.0.0.10 on E1-eth0 (port 1)
# h10 <-> h22 - h10 (E4-eth1:h10-eth0)

# --------------------------------------------------
# E4 Switch (Edge switch connected to h10)
# Ports:
# 1: h10-eth0 (10.0.0.10)
# 5: Connection to A5 (uplink)
# --------------------------------------------------
# Forward path (h10->h22): Send to A5 (port 5)
sudo ovs-ofctl add-flow E4 "priority=15,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:5"
# Return path (h22->h10): Deliver to h10 (port 1)
sudo ovs-ofctl add-flow E4 "priority=15,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# --------------------------------------------------
# A5 Switch (Aggregation switch)
# Ports:
# 1: Connection from E4
# 4: Connection to C4 (core)
# --------------------------------------------------
# Forward path: Forward to C4 (port 4)
sudo ovs-ofctl add-flow A5 "priority=15,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:4"
# Return path: Forward back to E4 (port 1)
sudo ovs-ofctl add-flow A5 "priority=15,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# --------------------------------------------------
# C4 Switch (Core switch)
# Ports:
# 2: Connection from A5
# 3: Connection to A8
# --------------------------------------------------
# Forward path: Forward to A8 (port 3)
sudo ovs-ofctl add-flow C4 "priority=15,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:3"
# Return path: Forward back to A5 (port 2)
sudo ovs-ofctl add-flow C4 "priority=15,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:2"

# --------------------------------------------------
# A8 Switch (Aggregation switch)
# Ports:
# 2: Connection to E8
# 4: Connection from C4
# --------------------------------------------------
# Forward path: Forward to E8 (port 2)
sudo ovs-ofctl add-flow A8 "priority=15,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:2"
# Return path: Forward back to C4 (port 4)
sudo ovs-ofctl add-flow A8 "priority=15,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:4"

# --------------------------------------------------
# E8 Switch (Edge switch connected to h22)
# Ports:
# 1: h22-eth0 (10.0.0.22)
# 5: Connection to A8 (uplink)
# --------------------------------------------------
# Forward path: Deliver to h22 (port 1)
sudo ovs-ofctl add-flow E8 "priority=15,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:1"
# Return path: Send back to A8 (port 5)
sudo ovs-ofctl add-flow E8 "priority=15,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:5"

echo "[+] Flows installed for h10 <-> h22 communication path"

##########################################
# Verification Commands
##########################################
echo ""
echo "[*] Flow installation complete. Run these commands to verify:"
echo "sudo ovs-ofctl dump-flows <swith>"
echo "h4 arping -I h4-eth0 10.0.0.1"
echo ""
echo "[*] Test connectivity with:"
echo "mininet> h1 ping h4"
echo "mininet> h3 ping h4"
echo "mininet> ..."

echo "h1 <-> h4, h3 <-> h4"
sudo ovs-ofctl dump-flows E1 | grep n_packets
sudo ovs-ofctl dump-flows A1 | grep n_packets
sudo ovs-ofctl dump-flows E2 | grep n_packets
echo "h10 <-> h22"
sudo ovs-ofctl dump-flows E4 | grep n_packets
sudo ovs-ofctl dump-flows A5 | grep n_packets
sudo ovs-ofctl dump-flows C4 | grep n_packets
sudo ovs-ofctl dump-flows A8 | grep n_packets
sudo ovs-ofctl dump-flows E8 | grep n_packets
# sudo h10 ping h22
# sudo h22 ping h10
echo "End"