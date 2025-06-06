#!/bin/bash

echo "Installing flow rules for bidirectional paths..."

# Define switches
switches=(E{1..18} A{1..18} C{1..9})

# Clear existing flows
for switch in "${switches[@]}"; do
    sudo ovs-ofctl del-flows "$switch"
    echo "Cleared flows on switch $switch"
done

# Base rules: allow ARP, drop all other traffic
for switch in "${switches[@]}"; do
    sudo ovs-ofctl add-flow "$switch" "priority=100,arp,actions=flood"
    sudo ovs-ofctl add-flow "$switch" "priority=1,actions=drop"
done

###########################################
# Path 1 Green: h1 (10.0.0.1) <-> h4 (10.0.0.4)
###########################################

# Adjust these output port numbers according to your topology
# Run `sudo ovs-ofctl show <switch>` to verify interface-port mapping

sudo ovs-ofctl add-flow E1 in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 in_port=1,actions=output:2
sudo ovs-ofctl add-flow E2 in_port=4,actions=output:1

sudo ovs-ofctl add-flow E2 in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 in_port=2,actions=output:1
sudo ovs-ofctl add-flow E1 in_port=4,actions=output:1

echo "âœ… Bidirectional rules installed for h1 <-> h4"

###########################################
# Path 2 Blue: h1 (10.0.0.3) <-> h4 (10.0.0.4)
###########################################

# Adjust these output port numbers according to your topology
# Run `sudo ovs-ofctl show <switch>` to verify interface-port mapping

sudo ovs-ofctl add-flow E1 in_port=3,actions=output:4
sudo ovs-ofctl add-flow A1 in_port=1,actions=output:2
sudo ovs-ofctl add-flow E2 in_port=4,actions=output:1

sudo ovs-ofctl add-flow E2 in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 in_port=2,actions=output:1
sudo ovs-ofctl add-flow E1 in_port=4,actions=output:1

echo
echo "ï¿½^|^e Bidirectional rules installed for h3 <-> h4"

###########################################
# Flow Dump for Debugging
###########################################

for s in E1 A1 C1 A2 E2; do
    echo -e "\n--- Flow table for $s ---"
    #sudo ovs-ofctl dump-flows $s
    #sudo ovs-ofctl show $s
done
