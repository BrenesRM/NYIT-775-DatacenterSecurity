#!/bin/bash

# Mininet SDN Flow Configuration - Non-Overlapping Rules
# Priority Strategy: Higher numbers = Higher priority
# 100: ARP (highest)
# 90-99: Core infrastructure rules
# 50-89: Specific host-to-host paths (differentiated by priority)
# 10-49: General routing rules
# 1: Drop all (lowest)

# Define all switches in the topology
switches=(E13 A14 E15)

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
# PINK PATH: h38 (10.0.0.38) <-> h43 (10.0.0.43)
# Route: h38 -> E13(port2->port6) -> A15(port1->port3) -> E15(port6->port1) -> h43
# Priority: 55 (lowest)
# ======================
echo "[*] Installing PINK PATH: h38 <-> h43 (Priority 55)..."

# E13 Switch Rules
sudo ovs-ofctl add-flow E13 "priority=55,in_port=2,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:6"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=6,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:2"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=2,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:6"
sudo ovs-ofctl add-flow E13 "priority=55,in_port=6,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:2"

# A15 Switch Rules
sudo ovs-ofctl add-flow A15 "priority=55,in_port=1,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:3"
sudo ovs-ofctl add-flow A15 "priority=55,in_port=3,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:1"
sudo ovs-ofctl add-flow A15 "priority=55,in_port=1,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:3"
sudo ovs-ofctl add-flow A15 "priority=55,in_port=3,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:1"

# E15 Switch Rules
sudo ovs-ofctl add-flow E15 "priority=55,in_port=6,arp,arp_spa=10.0.0.38,arp_tpa=10.0.0.43,actions=output:1"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=1,arp,arp_spa=10.0.0.43,arp_tpa=10.0.0.38,actions=output:6"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=6,ip,nw_src=10.0.0.38,nw_dst=10.0.0.43,actions=output:1"
sudo ovs-ofctl add-flow E15 "priority=55,in_port=1,ip,nw_src=10.0.0.43,nw_dst=10.0.0.38,actions=output:6"

##########################################
# VERIFICATION AND DIAGNOSTICS
##########################################

echo ""
echo "[*] Flow installation complete!"
echo ""
echo "=== PRIORITY SUMMARY ==="
echo "Priority 100: ARP flooding"
echo "Priority 70-79: Path 2 (h38 <-> h45) - PINK PATH"
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
echo "mininet> h38 ping -c3 h45  # Should use GREENPINK PATH (priority 65)"
echo ""
echo "# Monitor flow statistics:"
echo "watch 'sudo ovs-ofctl dump-flows E13 | grep n_packets | head -10'"

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
for switch in E13 A14 E15; do
    if sudo ovs-vsctl list-br | grep -q "^$switch$"; then
        conflict_check "$switch"
    fi
done

echo "Ã¢Å“â€¦ Conflict detection complete"
echo ""
echo "Ã°Å¸â€Â§ TROUBLESHOOTING TIPS:"
echo "1. If ping fails, check flow table order with priority"
echo "2. Use 'sudo ovs-ofctl dump-flows <switch>' to see active rules"
echo "3. Higher priority numbers take precedence"
echo "4. ARP must work first - check priority 100 rules"
echo "5. Use tcpdump to trace packet paths: 'sudo tcpdump -i <interface>'"
