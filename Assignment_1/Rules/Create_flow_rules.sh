#!/bin/bash

# Mininet SDN Flow Configuration Fix Script
# Addresses port mapping issues and adds missing host connectivity

# Define all involved switches
switches=(E1 A1 E2)

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

echo "[âœ”] All switches initialized with base flow rules."

###########################################
# Port Mapping Reference (verify with ovs-ofctl show <switch>):
# E1: eth1=port1(h1), eth3=port3(h3), eth4=port4(to A1)
# A1: eth1=port1(to E1), eth2=port2(to E2) 
# E2: eth1=port1(h4), eth4=port4(to A1)
###########################################

###########################################
# Path 1: h1 (10.0.0.1) <-> h4 (10.0.0.4)
###########################################

echo "[*] Installing h1 <-> h4 flows..."

# E1: Forward h1->h4 to A1, forward h4->h1 to h1
sudo ovs-ofctl add-flow E1 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# A1: Forward h1->h4 to E2, forward h4->h1 to E1  
sudo ovs-ofctl add-flow A1 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# E2: Forward h1->h4 to h4, forward h4->h1 to A1
sudo ovs-ofctl add-flow E2 "priority=10,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=10,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"

echo "âœ… h1 <-> h4 bidirectional rules installed"

##########################################
# Path 2: h3 (10.0.0.3) <-> h4 (10.0.0.4) 
##########################################

echo "[*] Installing h3 <-> h4 flows (FIXED)..."

# E1: Forward h3->h4 to A1, forward h4->h3 to h3 (FIXED: was going to h1!)
sudo ovs-ofctl add-flow E1 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:4" 
sudo ovs-ofctl add-flow E1 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:3"

# A1: Forward h3->h4 to E2, forward h4->h3 to E1
sudo ovs-ofctl add-flow A1 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:1"

# E2: Forward h3->h4 to h4 (FIXED: was going to A1!), forward h4->h3 to A1  
sudo ovs-ofctl add-flow E2 "priority=20,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=20,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:4"

echo "âœ… h3 <-> h4 bidirectional rules installed (CORRECTED)"

##########################################
# Additional Paths for h2, h5, h6 (if they exist)
##########################################

echo "[*] Installing flows for other hosts (h2, h5, h6)..."

# Assuming h2 is at 10.0.0.2 on E1-eth2 (port 2)
# h2 <-> h4
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.2,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.4,nw_dst=10.0.0.2,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.2,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.4,nw_dst=10.0.0.2,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.2,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.4,nw_dst=10.0.0.2,actions=output:4"

# Assuming h5 is at 10.0.0.5 on E2-eth2 (port 2) 
# h1 <-> h5, h3 <-> h5
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.1,nw_dst=10.0.0.5,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.1,actions=output:1"
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.3,nw_dst=10.0.0.5,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.3,actions=output:3"

sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.1,nw_dst=10.0.0.5,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.1,actions=output:1"
sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.3,nw_dst=10.0.0.5,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.3,actions=output:1"

sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.1,nw_dst=10.0.0.5,actions=output:2"
sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.1,actions=output:4"
sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.3,nw_dst=10.0.0.5,actions=output:2"
sudo ovs-ofctl add-flow E2 "priority=15,ip,nw_src=10.0.0.5,nw_dst=10.0.0.3,actions=output:4"

echo "âœ… Additional host connectivity rules installed"

##########################################
# Verification Commands
##########################################

echo ""
echo "[*] Flow installation complete. Run these commands to verify:"
echo "sudo ovs-ofctl dump-flows E1"
echo "sudo ovs-ofctl dump-flows A1" 
echo "sudo ovs-ofctl dump-flows E2"
echo ""
echo "[*] Test connectivity with:"
echo "mininet> h1 ping h4"
echo "mininet> h3 ping h4"
echo "mininet> h4 ping h1"
echo "mininet> h4 ping h3"

sudo ovs-ofctl dump-flows E1 | grep n_packets
sudo ovs-ofctl dump-flows A1 | grep n_packets
sudo ovs-ofctl dump-flows E2 | grep n_packets
