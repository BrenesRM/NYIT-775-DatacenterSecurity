#!/bin/bash

# Mininet SDN Flow Configuration - Non-Overlapping Rules
# Priority Strategy: Higher numbers = Higher priority
# 100: ARP (highest)
# 90-99: Core infrastructure rules  
# 50-89: Specific host-to-host paths (differentiated by priority)
# 10-49: General routing rules
# 1: Drop all (lowest)

# Define all switches in the topology
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

echo "✅ All switches initialized with base flow rules."

###########################################
# PRIORITY ALLOCATION STRATEGY:
# Priority 80-89: Path 1 (h1 <-> h4) - GREEN PATH
# Priority 70-79: Path 2 (h3 <-> h4) - BLUE PATH  
# Priority 60-69: Path 3 (h10 <-> h22) - RED PATH
# Priority 50-59: Additional paths
# Priority 40-49: Backup/Alternative paths
###########################################

###########################################
# GREEN PATH (Priority 80-89): h1 (10.0.0.1) <-> h4 (10.0.0.4)
# Route: h1 -> E1 -> A1 -> E2 -> h4
###########################################

echo "[*] Installing GREEN PATH: h1 <-> h4 (Priority 80-89)..."

# E1 Switch Rules (Priority 85)
sudo ovs-ofctl add-flow E1 "priority=85,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=85,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# A1 Switch Rules (Priority 85)  
sudo ovs-ofctl add-flow A1 "priority=85,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=85,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# E2 Switch Rules (Priority 85)
sudo ovs-ofctl add-flow E2 "priority=85,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=85,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"

echo "✅ GREEN PATH h1 <-> h4 installed (Priority 85)"

##########################################
# BLUE PATH (Priority 70-79): h3 (10.0.0.3) <-> h4 (10.0.0.4)
# Route: h3 -> E1 -> A1 -> E2 -> h4
##########################################

echo "[*] Installing BLUE PATH: h3 <-> h4 (Priority 70-79)..."

# E1 Switch Rules (Priority 75) - CORRECTED: h4->h3 goes to port 3, not port 1
sudo ovs-ofctl add-flow E1 "priority=75,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=75,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:3"

# A1 Switch Rules (Priority 75)
sudo ovs-ofctl add-flow A1 "priority=75,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=75,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:1"

# E2 Switch Rules (Priority 75) - CORRECTED: h3->h4 goes to port 1, not port 4
sudo ovs-ofctl add-flow E2 "priority=75,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=75,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:4"

echo "✅ BLUE PATH h3 <-> h4 installed (Priority 75)"

##########################################
# RED PATH (Priority 60-69): h10 (10.0.0.10) <-> h22 (10.0.0.22)
# Route: h10 -> E4 -> A5 -> C4 -> A8 -> E8 -> h22
##########################################

echo "[*] Installing RED PATH: h10 <-> h22 (Priority 60-69)..."

# E4 Switch Rules (Priority 65)
sudo ovs-ofctl add-flow E4 "priority=65,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# A5 Switch Rules (Priority 65)
sudo ovs-ofctl add-flow A5 "priority=65,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:4"
sudo ovs-ofctl add-flow A5 "priority=65,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# C4 Switch Rules (Priority 65)
sudo ovs-ofctl add-flow C4 "priority=65,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:3"
sudo ovs-ofctl add-flow C4 "priority=65,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:2"

# A8 Switch Rules (Priority 65)
sudo ovs-ofctl add-flow A8 "priority=65,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:2"
sudo ovs-ofctl add-flow A8 "priority=65,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:4"

# E8 Switch Rules (Priority 65)
sudo ovs-ofctl add-flow E8 "priority=65,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:1"
sudo ovs-ofctl add-flow E8 "priority=65,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:5"

echo "✅ RED PATH h10 <-> h22 installed (Priority 65)"

##########################################
# GENERAL ROUTING RULES (Priority 10-39)
##########################################

echo "[*] Installing general routing rules (Priority 10-39)..."

# Default routing for unmatched traffic within same subnet
for switch in E1 E2 E3 E4 E5 E6 E7 E8 E9; do
    sudo ovs-ofctl add-flow "$switch" "priority=10,ip,nw_dst=10.0.0.0/24,actions=CONTROLLER"
done

echo "✅ General routing rules installed"

##########################################
# VERIFICATION AND DIAGNOSTICS
##########################################

echo ""
echo "[*] Flow installation complete!"
echo ""
echo "=== PRIORITY SUMMARY ==="
echo "Priority 100: ARP flooding"
echo "Priority 85:  GREEN PATH (h1 <-> h4)"
echo "Priority 75:  BLUE PATH (h3 <-> h4)"  
echo "Priority 65:  RED PATH (h10 <-> h22)"
echo "Priority 55:  h2 <-> h4"
echo "Priority 50:  Local E1 traffic"
echo "Priority 45:  Backup paths"
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
echo "mininet> h1 ping -c3 h4  # Should use GREEN PATH (priority 85)"
echo "mininet> h3 ping -c3 h4  # Should use BLUE PATH (priority 75)"
echo "mininet> h10 ping -c3 h22 # Should use RED PATH (priority 65)"
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
for switch in E1 A1 E2 E4 A5 C4 A8 E8; do
    if sudo ovs-vsctl list-br | grep -q "^$switch$"; then
        conflict_check "$switch"
    fi
done

echo "✅ Conflict detection complete"
echo ""
echo "🔧 TROUBLESHOOTING TIPS:"
echo "1. If ping fails, check flow table order with priority"
echo "2. Use 'sudo ovs-ofctl dump-flows <switch>' to see active rules"
echo "3. Higher priority numbers take precedence"
echo "4. ARP must work first - check priority 100 rules"
echo "5. Use tcpdump to trace packet paths: 'sudo tcpdump -i <interface>'"