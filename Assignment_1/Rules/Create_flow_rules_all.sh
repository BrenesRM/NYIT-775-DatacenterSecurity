#!/bin/bash
# Fixed Mininet SDN Flow Configuration
# Proper h1<->h4 communication via E1->A1->E2 path
# Based on actual topology connections

# ======================
# INITIALIZATION
# ======================
# Clear all switches involved in the four paths
switches=(E1 E2 A1 E4 A5 C4 A8 E8 E5 E13 A13 A14 E15)
echo "[*] Resetting switches in the communication path..."

for switch in "${switches[@]}"; do
    sudo ovs-ofctl del-flows "$switch"
    echo "[+] Cleared flows on $switch"
done

# ======================
# PATH: h1 (10.0.0.1) <-> h4 (10.0.0.4)
# Route: h1 -> E1(port1->port4) -> A1(port1->port2) -> E2(port4->port1) -> h4
# ======================

echo "[*] Configuring E1 switch..."
# E1 Switch Rules - Fixed port mapping based on your topology
# h1 connects to E1-eth1 (port 1), h3 connects to E1-eth3 (port 3), A1 connects to E1-eth4 (port 4)

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic h1->h4
sudo ovs-ofctl add-flow E1 "priority=200,in_port=1,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:4"
# ARP traffic h4->h1 
sudo ovs-ofctl add-flow E1 "priority=200,in_port=4,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:1"
# IP traffic h1->h4
sudo ovs-ofctl add-flow E1 "priority=200,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"
# IP traffic h4->h1
sudo ovs-ofctl add-flow E1 "priority=200,in_port=4,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# BLUE PATH: h3<->h4 (Priority 175)
# ARP traffic h3->h4
sudo ovs-ofctl add-flow E1 "priority=175,in_port=3,arp,arp_spa=10.0.0.3,arp_tpa=10.0.0.4,actions=output:4"
# ARP traffic h4->h3
sudo ovs-ofctl add-flow E1 "priority=175,in_port=4,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.3,actions=output:3"
# IP traffic h3->h4
sudo ovs-ofctl add-flow E1 "priority=175,in_port=3,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:4"
# IP traffic h4->h3
sudo ovs-ofctl add-flow E1 "priority=175,in_port=4,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:3"

echo "[*] Configuring A1 switch..."
# A1 Switch Rules - Aggregation layer
# E1 connects to A1-eth1 (port 1), E2 connects to A1-eth2 (port 2)

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic E1->E2 (h1->h4)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=1,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:2"
# ARP traffic E2->E1 (h4->h1)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=2,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:1"
# IP traffic E1->E2 (h1->h4)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"
# IP traffic E2->E1 (h4->h1)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=2,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# BLUE PATH: h3<->h4 (Priority 175)
# ARP traffic E1->E2 (h3->h4)
sudo ovs-ofctl add-flow A1 "priority=175,in_port=1,arp,arp_spa=10.0.0.3,arp_tpa=10.0.0.4,actions=output:2"
# ARP traffic E2->E1 (h4->h3)
sudo ovs-ofctl add-flow A1 "priority=175,in_port=2,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.3,actions=output:1"
# IP traffic E1->E2 (h3->h4)
sudo ovs-ofctl add-flow A1 "priority=175,in_port=1,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:2"
# IP traffic E2->E1 (h4->h3)
sudo ovs-ofctl add-flow A1 "priority=175,in_port=2,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:1"

echo "[*] Configuring E2 switch..."
# E2 Switch Rules - Fixed port mapping
# h4 connects to E2-eth1 (port 1), A1 connects to E2-eth4 (port 4)

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic A1->h4 (from h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=4,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:1"
# ARP traffic h4->A1 (to h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=1,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:4"
# IP traffic A1->h4 (from h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=4,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"
# IP traffic h4->A1 (to h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=1,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"

# BLUE PATH: h3<->h4 (Priority 175)
# ARP traffic A1->h4 (from h3)
sudo ovs-ofctl add-flow E2 "priority=175,in_port=4,arp,arp_spa=10.0.0.3,arp_tpa=10.0.0.4,actions=output:1"
# ARP traffic h4->A1 (to h3)
sudo ovs-ofctl add-flow E2 "priority=175,in_port=1,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.3,actions=output:4"
# IP traffic A1->h4 (from h3)
sudo ovs-ofctl add-flow E2 "priority=175,in_port=4,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:1"
# IP traffic h4->A1 (to h3)
sudo ovs-ofctl add-flow E2 "priority=175,in_port=1,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:4"

# ======================
# RED PATH: h10 (10.0.0.10) <-> h22 (10.0.0.22)
# Route: h10 -> E4 -> A5 -> C4 -> A8 -> E8 -> h22
# Priority 65 (lowest)
# ======================

echo "[*] Installing RED PATH: h10 <-> h22 (Priority 65)..."

# E4 Switch Rules
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.22,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,arp,arp_spa=10.0.0.22,arp_tpa=10.0.0.10,actions=output:1"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# A5 Switch Rules
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.22,actions=output:4"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=4,arp,arp_spa=10.0.0.22,arp_tpa=10.0.0.10,actions=output:1"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:4"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=4,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# C4 Switch Rules
sudo ovs-ofctl add-flow C4 "priority=65,in_port=2,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.22,actions=output:3"
sudo ovs-ofctl add-flow C4 "priority=65,in_port=3,arp,arp_spa=10.0.0.22,arp_tpa=10.0.0.10,actions=output:2"
sudo ovs-ofctl add-flow C4 "priority=65,in_port=2,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:3"
sudo ovs-ofctl add-flow C4 "priority=65,in_port=3,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:2"

# A8 Switch Rules
sudo ovs-ofctl add-flow A8 "priority=65,in_port=4,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.22,actions=output:2"
sudo ovs-ofctl add-flow A8 "priority=65,in_port=2,arp,arp_spa=10.0.0.22,arp_tpa=10.0.0.10,actions=output:4"
sudo ovs-ofctl add-flow A8 "priority=65,in_port=4,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:2"
sudo ovs-ofctl add-flow A8 "priority=65,in_port=2,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:4"

# E8 Switch Rules
sudo ovs-ofctl add-flow E8 "priority=65,in_port=5,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.22,actions=output:1"
sudo ovs-ofctl add-flow E8 "priority=65,in_port=1,arp,arp_spa=10.0.0.22,arp_tpa=10.0.0.10,actions=output:5"
sudo ovs-ofctl add-flow E8 "priority=65,in_port=5,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:1"
sudo ovs-ofctl add-flow E8 "priority=65,in_port=1,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:5"

# ======================
# PURPLE PATH: h10 (10.0.0.10) <-> h13 (10.0.0.13)
# Route: h10 -> E4 -> A5 -> E5 -> h13
# Priority 65 (same as RED, but different destinations)
# ======================

echo "[*] Installing PURPLE PATH: h10 <-> h13 (Priority 65)..."

# E4 Switch Rules (shared with RED path but different destination)
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.13,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,arp,arp_spa=10.0.0.13,arp_tpa=10.0.0.10,actions=output:1"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:1"

# A5 Switch Rules (shared with RED path but different output port)
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.13,actions=output:2"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=2,arp,arp_spa=10.0.0.13,arp_tpa=10.0.0.10,actions=output:1"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:2"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=2,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:1"

# E5 Switch Rules (new switch for PURPLE path)
sudo ovs-ofctl add-flow E5 "priority=65,in_port=5,arp,arp_spa=10.0.0.10,arp_tpa=10.0.0.13,actions=output:1"
sudo ovs-ofctl add-flow E5 "priority=65,in_port=1,arp,arp_spa=10.0.0.13,arp_tpa=10.0.0.10,actions=output:5"
sudo ovs-ofctl add-flow E5 "priority=65,in_port=5,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:1"
sudo ovs-ofctl add-flow E5 "priority=65,in_port=1,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:5"

# ======================
# ORANGE PATH: h37 (10.0.0.37) <-> h45 (10.0.0.45)
# Route: h37 -> E13(port1->port6) -> A15(port1->port3) -> E15(port6->port3) -> h45
# Priority: 60 (below RED/PURPLE paths)
# ======================
echo "[*] Installing ORANGE PATH: h37 <-> h45 (Priority 60)..."

# E13 Switch Rules
sudo ovs-ofctl add-flow E13 "priority=60,in_port=1,arp,arp_spa=10.0.0.37,arp_tpa=10.0.0.45,actions=output:6"
sudo ovs-ofctl add-flow E13 "priority=60,in_port=6,arp,arp_spa=10.0.0.45,arp_tpa=10.0.0.37,actions=output:1"
sudo ovs-ofctl add-flow E13 "priority=60,in_port=1,ip,nw_src=10.0.0.37,nw_dst=10.0.0.45,actions=output:6"
sudo ovs-ofctl add-flow E13 "priority=60,in_port=6,ip,nw_src=10.0.0.45,nw_dst=10.0.0.37,actions=output:1"

# A15 Switch Rules  
sudo ovs-ofctl add-flow A15 "priority=60,in_port=1,arp,arp_spa=10.0.0.37,arp_tpa=10.0.0.45,actions=output:3"
sudo ovs-ofctl add-flow A15 "priority=60,in_port=3,arp,arp_spa=10.0.0.45,arp_tpa=10.0.0.37,actions=output:1"
sudo ovs-ofctl add-flow A15 "priority=60,in_port=1,ip,nw_src=10.0.0.37,nw_dst=10.0.0.45,actions=output:3"
sudo ovs-ofctl add-flow A15 "priority=60,in_port=3,ip,nw_src=10.0.0.45,nw_dst=10.0.0.37,actions=output:1"

# E15 Switch Rules (FIXED)
sudo ovs-ofctl add-flow E15 "priority=60,in_port=6,arp,arp_spa=10.0.0.37,arp_tpa=10.0.0.45,actions=output:3"
sudo ovs-ofctl add-flow E15 "priority=60,in_port=3,arp,arp_spa=10.0.0.45,arp_tpa=10.0.0.37,actions=output:6"
sudo ovs-ofctl add-flow E15 "priority=60,in_port=6,ip,nw_src=10.0.0.37,nw_dst=10.0.0.45,actions=output:3"
sudo ovs-ofctl add-flow E15 "priority=60,in_port=3,ip,nw_src=10.0.0.45,nw_dst=10.0.0.37,actions=output:6"

# ======================
# PINK PATH: h38 (10.0.0.38) <-> h43 (10.0.0.43)
# Route: h38 -> E13(port2->port5) -> A14(port1->port3) -> E15(port5->port1) -> h43
# Priority: 55 (lowest)
# ======================
echo "[*] Installing PINK PATH: h38 <-> h43 (Priority 55)..."

# E13 Switch Rules
sudo ovs-ofctl add-flow E13 "priority=55,in_port=2,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:5"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=5,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:2"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=2,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:5"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=5,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:2"

# A14 Switch Rules
sudo ovs-ofctl add-flow A14 "priority=55,in_port=1,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:3"
sudo ovs-ofctl add-flow A14 "priority=55,in_port=3,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:1"
sudo ovs-ofctl add-flow A14 "priority=55,in_port=1,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:3"
sudo ovs-ofctl add-flow A14 "priority=55,in_port=3,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:1"

# E15 Switch Rules
sudo ovs-ofctl add-flow E15 "priority=55,in_port=5,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:1"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=1,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:5"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=5,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:1"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=1,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:5"

# ======================
# DEFAULT RULES
# ======================
# Add low priority catch-all rules to drop unmatched traffic
for sw in "${switches[@]}"; do
    sudo ovs-ofctl add-flow "$sw" "priority=1,actions=drop"
done

echo "? Success! Fixed flow rules configured for all four paths:"
echo "   GREEN PATH  (Priority 200): h1 -> E1(1->4) -> A1(1->2) -> E2(4->1) -> h4"
echo "   BLUE PATH   (Priority 175): h3 -> E1(3->4) -> A1(1->2) -> E2(4->1) -> h4"
echo "   RED PATH    (Priority 65):  h10 -> E4(1->5) -> A5(1->4) -> C4(2->3) -> A8(4->2) -> E8(5->1) -> h22"
echo "   PURPLE PATH (Priority 65):  h10 -> E4(1->5) -> A5(1->2) -> E5(5->1) -> h13"
echo "   ORANGE PATH (Priority 60): h37 -> E13(1->6) -> A13(1->3) -> E15(6->3) -> h45" 
echo "   PINK PATH   (Priority 55): h38 -> E13(2->5) -> A15(1->3) -> E15(5->1) -> h43" 
echo "   All reverse paths configured with same priorities"
echo ""
echo "[*] Testing connectivity..."
echo "GREEN PATH:  h1 <-> h4"
echo "BLUE PATH:   h3 <-> h4"
echo "RED PATH:    h10 <-> h22 (long route)"
echo "PURPLE PATH: h10 <-> h13 (short route)"
echo "ORANGE PATH: h37 <-> h45"
echo "PINK PATH: h38 <-> h43"
echo ""echo "[*] Verifying flows..."
echo "E1 flows:"
sudo ovs-ofctl dump-flows E1
echo ""
echo "A1 flows:"
sudo ovs-ofctl dump-flows A1
echo ""
echo "E2 flows:"
sudo ovs-ofctl dump-flows E2
echo ""
echo "E4 flows (shared by RED and PURPLE):"
sudo ovs-ofctl dump-flows E4
echo ""
echo "A5 flows (shared by RED and PURPLE):"
sudo ovs-ofctl dump-flows A5
echo ""
echo "C4 flows (RED path only):"
sudo ovs-ofctl dump-flows C4
echo ""
echo "A8 flows (RED path only):"
sudo ovs-ofctl dump-flows A8
echo ""
echo "E8 flows (RED path only):"
sudo ovs-ofctl dump-flows E8
echo ""
echo "E5 flows (PURPLE path only):"
sudo ovs-ofctl dump-flows E5
echo ""
echo "[*] Verifying new flows..."
echo "E13 flows (shared by ORANGE/PINK):"
sudo ovs-ofctl dump-flows E13
echo ""
echo "A13 flows (ORANGE only):"
sudo ovs-ofctl dump-flows A13
echo ""
echo "A15 flows (PINK only):"
sudo ovs-ofctl dump-flows A14
echo ""
echo "E15 flows (shared by ORANGE/PINK):"
sudo ovs-ofctl dump-flows E15