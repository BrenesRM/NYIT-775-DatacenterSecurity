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

###########################################
# PINK PATH (Priority 60-65): h38 <-> h45
# Forward Path: h38 -> E13(eth2) -> E13(eth5) -> A14(eth1) -> A14(eth3) -> E15(eth5) -> E15(eth3) -> h45
# Reverse Path: h45 -> E15(eth3) -> E15(eth5) -> A14(eth3) -> A14(eth1) -> E13(eth5) -> E13(eth2) -> h38
###########################################

echo "[*] Installing PINK PATH: h38 <-> h45 (Priority 65)..."

# --- E13 Switch (h38 connected to E13-eth2) ---
# Forward: h38 -> output to A14 (port 5)
sudo ovs-ofctl add-flow E13 "priority=65,in_port=2,actions=output:5"
# Reverse: From A14 (port 5) -> output to h38 (port 2)
sudo ovs-ofctl add-flow E13 "priority=65,in_port=5,actions=output:2"

# --- A14 Switch (Connected to E13-eth5 and E15-eth5) ---
# Forward: From E13 (port 1) -> output to E15 (port 3)
sudo ovs-ofctl add-flow A14 "priority=65,in_port=1,actions=output:3"
# Reverse: From E15 (port 3) -> output back to E13 (port 1)
sudo ovs-ofctl add-flow A14 "priority=65,in_port=3,actions=output:1"

# --- E15 Switch (h45 connected to E15-eth3) ---
# Forward: From A14 (port 5) -> output to h45 (port 3)
sudo ovs-ofctl add-flow E15 "priority=65,in_port=5,actions=output:3"
# Reverse: h45 -> output back to A14 (port 5)
sudo ovs-ofctl add-flow E15 "priority=65,in_port=3,actions=output:5"

echo "[âœ“] PINK PATH h38 <-> h45 installed (Priority 65)"

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
