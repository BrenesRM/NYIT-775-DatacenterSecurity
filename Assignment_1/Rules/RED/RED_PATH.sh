#!/bin/bash

# Mininet SDN Flow Configuration - Non-Overlapping Rules
# Priority Strategy: Higher numbers = Higher priority
# 100: ARP (highest)
# 90-99: Core infrastructure rules  
# 50-89: Specific host-to-host paths (differentiated by priority)
# 10-49: General routing rules
# 1: Drop all (lowest)

# Define all switches in the topology
switches=(E4 A5 C4 A8 E8)

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

echo "âœ… All switches initialized with base flow rules."

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

##########################################
# VERIFICATION AND DIAGNOSTICS
##########################################

echo ""
echo "[*] Flow installation complete!"
echo ""
echo "=== PRIORITY SUMMARY ==="
echo "Priority 100: ARP flooding"
echo "Priority 60 RED PATH (h1 <-> h4)"
echo "Priority 10:  General routing"
echo "Priority 1:   Drop all"
echo ""

echo "=== VERIFICATION COMMANDS ==="
echo "# Check flow tables:"
echo "sudo ovs-ofctl dump-flows E1 | sort -k3 -nr"
echo "sudo ovs-ofctl dump-flows A1 | sort -k3 -nr"  
echo "sudo ovs-ofctl dump-flows E2 | sort -k3 -nr"
echo ""
echo "# Test connectivity:"
echo "mininet> h10 ping -c3 h22  # Should use GREEN PATH (priority 60)"
echo ""
echo "# Monitor flow statistics:"
echo "watch 'sudo ovs-ofctl dump-flows E1 | grep n_packets | head -10'"

##########################################
# CONFLICT DETECTION FUNCTION
##########################################

echo ""
echo "[*] Running conflict detection..."

conflict_check() {
    local switch=$1
    echo "Checking $switch for potential conflicts..."
    
    # Get flows sorted by priority (highest first)
    flows=$(sudo ovs-ofctl dump-flows "$switch" 2>/dev/null | grep -E "priority=" | sort -k3 -nr)
    
    # Count flows by priority
    priorities=$(echo "$flows" | grep -o "priority=[0-9]*" | sort | uniq -c)
    
    echo "Flow count by priority for $switch:"
    echo "$priorities" | while read count priority; do
        echo "  $priority: $count flows"
    done
    echo ""
}

# Check key switches for conflicts
for switch in E4 A5 C4 A8 E8; do
    if sudo ovs-vsctl list-br | grep -q "^$switch$"; then
        conflict_check "$switch"
    fi
done

echo "âœ… Conflict detection complete"
echo ""
echo "ðŸ”§ TROUBLESHOOTING TIPS:"
echo "1. If ping fails, check flow table order with priority"
echo "2. Use 'sudo ovs-ofctl dump-flows <switch>' to see active rules"
echo "3. Higher priority numbers take precedence"
echo "4. ARP must work first - check priority 100 rules"
echo "5. Use tcpdump to trace packet paths: 'sudo tcpdump -i <interface>'"