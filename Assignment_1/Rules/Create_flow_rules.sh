#!/bin/bash

# Complete Path Flow Rules for h1 <-> h4
echo "Installing complete end-to-end flow rules..."

# Clear existing flows on all relevant switches
for switch in E1 E2 A1 A2 C1; do
    sudo ovs-ofctl del-flows $switch
    echo clear switch $switch
done

# Base rules for all switches
for switch in E1 E2 A1 A2 C1; do
    # Allow ARP
    sudo ovs-ofctl add-flow $switch "priority=100,arp,actions=flood"
    # Drop all else by default
    sudo ovs-ofctl add-flow $switch "priority=1,actions=drop"
done

# h1 (10.0.0.1) is connected to E1-eth1
# h4 (10.0.0.4) is connected to E2-eth1

# E1 Rules (edge switch for h1)
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:flood"  # To A1
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:flood"  # To h1

# A1 Rules (aggregation switch)
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:flood"  # To C1
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:flood"  # To E1

# C1 Rules (core switch)
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:flood"  # To A2
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:flood"  # To A1

# A2 Rules (aggregation switch)
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:flood"  # To E2
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:flood"  # To C1

# E2 Rules (edge switch for h4)
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:flood"  # To h4
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:flood"  # To A2

echo "Complete end-to-end flow rules installed for h1 <-> h4"

echo dump-flows E1
sudo ovs-ofctl dump-flows E1
echo dump-flows A1
sudo ovs-ofctl dump-flows A1
echo dump-flows C1
sudo ovs-ofctl dump-flows C1
