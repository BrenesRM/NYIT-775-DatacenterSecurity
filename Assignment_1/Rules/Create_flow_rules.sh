#!/bin/bash

# === Define Switches ===
switches=(E{1..18} A{1..18} C{1..9})

echo "ðŸ” Clearing all flows and applying base rules..."

# === Clear Flows and Apply Base Rules (ARP + Drop) ===
for switch in "${switches[@]}"; do
    echo "â†’ Resetting $switch"
    sudo ovs-ofctl del-flows "$switch"
    #sudo ovs-ofctl add-flow "$switch" "priority=100,arp,actions=flood"
    sudo ovs-ofctl add-flow "$switch" "priority=1,actions=drop"
done

echo "âœ… All switches reset with base ARP and DROP rules."

# === (Optional) Highlight Critical Path ARP Again ===
# These are already covered above, but kept here for clarity and future extension
critical_arp_switches=(E1 A1 E2)

echo "ðŸ” Re-asserting ARP flood on critical switches..."

for sw in "${critical_arp_switches[@]}"; do
    sudo ovs-ofctl add-flow "$sw" "priority=100,arp,actions=flood"
    echo "âœ“ Re-applied ARP flood on $sw"
done

echo "âœ… ARP flood re-asserted on critical path switches."


###########################################
# Path 1 Green: h1 (10.0.0.1) <-> h4 (10.0.0.4)
###########################################

# Adjust these output port numbers according to your topology
# Run `sudo ovs-ofctl show <switch>` to verify interface-port mapping

sudo ovs-ofctl add-flow E1 priority=10,in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 priority=10,in_port=1,actions=output:2
sudo ovs-ofctl add-flow E2 priority=10,in_port=4,actions=output:1

sudo ovs-ofctl add-flow E2 priority=10,in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 priority=10,in_port=2,actions=output:1
sudo ovs-ofctl add-flow E1 priority=10,in_port=4,actions=output:1

echo "Ã¢Å“â€¦ Bidirectional rules installed for h1 <-> h4"

##########################################
# Path 2 Blue: h1 (10.0.0.3) <-> h4 (10.0.0.4)
###########################################

# Adjust these output port numbers according to your topology
# Run `sudo ovs-ofctl show <switch>` to verify interface-port mapping

sudo ovs-ofctl add-flow E1 priority=20,in_port=3,actions=output:4
sudo ovs-ofctl add-flow A1 priority=20,in_port=1,actions=output:2
sudo ovs-ofctl add-flow E2 priority=20,in_port=4,actions=output:1

sudo ovs-ofctl add-flow E2 priority=20,in_port=1,actions=output:4
sudo ovs-ofctl add-flow A1 priority=20,in_port=2,actions=output:1
sudo ovs-ofctl add-flow E1 priority=20,in_port=4,actions=output:1

echo
echo "Ã¯Â¿Â½^|^e Bidirectional rules installed for h3 <-> h4"


###########################################
# Flow Dump for Debugging
###########################################

for s in E1 A1 E2; do
    echo -e "\n--- Flow table for $s ---"
    #sudo ovs-ofctl dump-flows $s
    #sudo ovs-ofctl show $s
done
