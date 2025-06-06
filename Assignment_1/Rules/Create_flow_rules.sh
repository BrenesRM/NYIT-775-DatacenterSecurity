#!/bin/bash

# Complete Path Flow Rules for h1 <-> h4
echo "Installing complete end-to-end flow rules..."

# Complete Path Flow Rules for h1 <-> h4
echo "Installing complete end-to-end flow rules..."

# Clear existing flows on all relevant switches
for switch in E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 E11 E12 E13 E14 E15 E16 E17 E18 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16 A17 A18 C1 C2 C3 C4 C5 C6 C7 C8 C9; do
    sudo ovs-ofctl del-flows $switch
    echo clear switch $switch
done

# Base rules for all switches
for switch in ; do E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 E11 E12 E13 E14 E15 E16 E17 E18 A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16 A17 A18 C1 C2 C3 C4 C5 C6 C7 C8 C9
    # Allow ARP
    sudo ovs-ofctl add-flow $switch "priority=100,arp,actions=flood"
    # Drop all else by default
    sudo ovs-ofctl add-flow $switch "priority=1,actions=drop"
done

# Green path between h1 and h4
# h1 (10.0.0.1) is connected to E1-eth1
# h4 (10.0.0.4) is connected to E2-eth1
# use in mininet> net to identify the networks

# E1 Rules (edge switch for h1)
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"  # To A1
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"  # To h1

# A1 Rules (aggregation switch)
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"  # To C1
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"  # To E1

# C1 Rules (core switch)
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"  # To A1
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:2"  # To A2

# A4 Rules (aggregation switch)
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"  # To A2
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"  # To E2

# E4 Rules (edge switch for h4)
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"  # To h4
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:5"  # To A2

echo "Complete end-to-end flow rules installed for h1 <-> h4"

#----------------------------------------------

# h1 (10.0.0.1) is connected to E1-eth1
# h4 (10.0.0.4) is connected to E2-eth1
# use in mininet> net to identify the networks

# E1 Rules (edge switch for h1)
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"  # To A1
sudo ovs-ofctl add-flow E1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"  # To h1

# A1 Rules (aggregation switch)
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"  # To C1
sudo ovs-ofctl add-flow A1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"  # To E1

# C1 Rules (core switch)
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"  # To A1
sudo ovs-ofctl add-flow C1 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:2"  # To A2

# A4 Rules (aggregation switch)
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"  # To A2
sudo ovs-ofctl add-flow A2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"  # To E2

# E4 Rules (edge switch for h4)
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"  # To h4
sudo ovs-ofctl add-flow E2 "priority=200,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:5"  # To A2

echo "Complete end-to-end flow rules installed for h1 <-> h4"



echo dump-flows E1
sudo ovs-ofctl dump-flows E1
echo dump-flows A1
sudo ovs-ofctl dump-flows A1
echo dump-flows C1
sudo ovs-ofctl dump-flows C1


echo "Complete end-to-end flow rules installed for h1 <-> h4"

echo dump-flows E1
sudo ovs-ofctl dump-flows E1
echo dump-flows A1
sudo ovs-ofctl dump-flows A1
echo dump-flows C1
sudo ovs-ofctl dump-flows C1