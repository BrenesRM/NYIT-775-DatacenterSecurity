#!/bin/bash

# Mininet SDN Flow Configuration - Non-Overlapping Rules
# Priority Strategy: Higher numbers = Higher priority
# 100: ARP (highest)
# 90-99: Core infrastructure rules  
# 50-89: Specific host-to-host paths (differentiated by priority)
# 10-49: General routing rules
# 1: Drop all (lowest)
# Review disable priority, add arp, into the rule. **********

# Define all switches in the topology
switches=(E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 E11 E12 E13 E14 E15 E16 E17 E18 
          A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12 A13 A14 A15 A16 A17 A18 
          C1 C2 C3 C4 C5 C6 C7 C8 C9)

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
# GREEN PATH (Priority 85): h1 (10.0.0.1) <-> h4 (10.0.0.4)
# Route: h1 -> E1 -> A1 -> E2 -> h4
###########################################

echo "[*] Installing GREEN PATH: h1 <-> h4 (Priority 85)..."

# E1 Switch Rules
sudo ovs-ofctl add-flow E1 "priority=85,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=85,in_port=4,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# A1 Switch Rules  
sudo ovs-ofctl add-flow A1 "priority=85,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=85,in_port=2,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# E2 Switch Rules
sudo ovs-ofctl add-flow E2 "priority=85,in_port=4,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=85,in_port=1,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"

echo "✅ GREEN PATH h1 <-> h4 installed (Priority 85)"

###########################################
# BLUE PATH (Priority 75): h3 (10.0.0.3) <-> h4 (10.0.0.4)
# Route: h3 -> E1 -> A1 -> E2 -> h4
###########################################

echo "[*] Installing BLUE PATH: h3 <-> h4 (Priority 75)..."

# E1 Switch Rules
sudo ovs-ofctl add-flow E1 "priority=75,in_port=3,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:4"
sudo ovs-ofctl add-flow E1 "priority=75,in_port=4,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:3"

# A1 Switch Rules
sudo ovs-ofctl add-flow A1 "priority=75,in_port=1,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:2"
sudo ovs-ofctl add-flow A1 "priority=75,in_port=2,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:1"

# E2 Switch Rules
sudo ovs-ofctl add-flow E2 "priority=75,in_port=4,ip,nw_src=10.0.0.3,nw_dst=10.0.0.4,actions=output:1"
sudo ovs-ofctl add-flow E2 "priority=75,in_port=1,ip,nw_src=10.0.0.4,nw_dst=10.0.0.3,actions=output:4"

echo "✅ BLUE PATH h3 <-> h4 installed (Priority 75)"

###########################################
# RED PATH (Priority 65): h10 (10.0.0.10) <-> h22 (10.0.0.22)
# Route: h10 -> E4 -> A5 -> C4 -> A8 -> E8 -> h22
###########################################

echo "[*] Installing RED PATH: h10 <-> h22 (Priority 65)..."

# E4 Switch Rules
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# A5 Switch Rules
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:4"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=4,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:1"

# C4 Switch Rules
sudo ovs-ofctl add-flow C4 "priority=65,in_port=2,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:3"
sudo ovs-ofctl add-flow C4 "priority=65,in_port=3,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:2"

# A8 Switch Rules
sudo ovs-ofctl add-flow A8 "priority=65,in_port=4,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:2"
sudo ovs-ofctl add-flow A8 "priority=65,in_port=2,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:4"

# E8 Switch Rules
sudo ovs-ofctl add-flow E8 "priority=65,in_port=5,ip,nw_src=10.0.0.10,nw_dst=10.0.0.22,actions=output:1"
sudo ovs-ofctl add-flow E8 "priority=65,in_port=1,ip,nw_src=10.0.0.22,nw_dst=10.0.0.10,actions=output:5"

echo "✅ RED PATH h10 <-> h22 installed (Priority 65)"

###########################################
# PURPLE PATH (Priority 65): h10 (10.0.0.10) <-> h13 (10.0.0.13)
# Route: h10 -> E4 -> A5 -> E5 -> h13
###########################################

echo "[*] Installing PURPLE PATH: h10 <-> h13 (Priority 65)..."

# E4 Switch Rules
sudo ovs-ofctl add-flow E4 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:5"
sudo ovs-ofctl add-flow E4 "priority=65,in_port=5,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:1"

# A5 Switch Rules
sudo ovs-ofctl add-flow A5 "priority=65,in_port=1,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:2"
sudo ovs-ofctl add-flow A5 "priority=65,in_port=2,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:1"

# E5 Switch Rules
sudo ovs-ofctl add-flow E5 "priority=65,in_port=5,ip,nw_src=10.0.0.10,nw_dst=10.0.0.13,actions=output:1"
sudo ovs-ofctl add-flow E5 "priority=65,in_port=1,ip,nw_src=10.0.0.13,nw_dst=10.0.0.10,actions=output:5"

echo "✅ PURPLE PATH h10 <-> h13 installed (Priority 65)"

###########################################
# ORANGE PATH (Priority 65): h37 <-> h45
# Route: h37 -> E13 -> A13 -> E15 -> h45
###########################################

echo "[*] Installing ORANGE PATH: h37 <-> h45 (Priority 65)..."

# E13 Switch Rules
sudo ovs-ofctl add-flow E13 "priority=65,in_port=1,actions=output:4"
sudo ovs-ofctl add-flow E13 "priority=65,in_port=4,actions=output:1"

# A13 Switch Rules
sudo ovs-ofctl add-flow A13 "priority=65,in_port=1,actions=output:3"
sudo ovs-ofctl add-flow A13 "priority=65,in_port=3,actions=output:1"

# E15 Switch Rules
sudo ovs-ofctl add-flow E15 "priority=65,in_port=4,actions=output:3"
sudo ovs-ofctl add-flow E15 "priority=65,in_port=3,actions=output:4"

echo "✅ ORANGE PATH h37 <-> h45 installed (Priority 65)"

###########################################
# PINK PATH (Priority 65): h38 <-> h45
# Route: h38 -> E13 -> A14 -> E15 -> h45
###########################################

echo "[*] Installing PINK PATH: h38 <-> h45 (Priority 65)..."

# E13 Switch Rules
sudo ovs-ofctl add-flow E13 "priority=65,in_port=2,actions=output:5"
sudo ovs-ofctl add-flow E13 "priority=65,in_port=5,actions=output:2"

# A14 Switch Rules
sudo ovs-ofctl add-flow A14 "priority=65,in_port=1,actions=output:3"
sudo ovs-ofctl add-flow A14 "priority=65,in_port=3,actions=output:1"

# E15 Switch Rules
sudo ovs-ofctl add-flow E15 "priority=65,in_port=5,actions=output:3"
sudo ovs-ofctl add-flow E15 "priority=65,in_port=3,actions=output:5"

echo "✅ PINK PATH h38 <-> h45 installed (Priority 65)"

##########################################
# GENERAL ROUTING RULES (Priority 10)
##########################################

echo "[*] Installing general routing rules (Priority 10)..."

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
echo "Priority 65:  RED/PURPLE/ORANGE/PINK PATHS"
echo "Priority 10:  General routing"
echo "Priority 1:   Drop all"
echo ""

echo "=== VERIFICATION COMMANDS ==="
echo "sudo ovs-ofctl dump-flows E1 | sort -k3 -nr"
echo "sudo ovs-ofctl dump-flows A1 | sort -k3 -nr"  
echo "mininet> h1 ping -c3 h4"
echo "mininet> h3 ping -c3 h4"
echo "mininet> h10 ping -c3 h22"

##########################################
# CONFLICT DETECTION
##########################################

echo ""
echo "[*] Running conflict detection..."

for switch in E1 A1 E2 E4 A5 C4 A8 E8 E13 A13 A14 E15; do
    if sudo ovs-vsctl list-br | grep -q "^$switch$"; then
        echo "Checking $switch..."
        sudo ovs-ofctl dump-flows "$switch" | grep -E "priority=" | 
            awk '{print $3}' | sort | uniq -c | 
            awk '{print "  Priority " $2 ": " $1 " rules"}'
        echo ""
    fi
done

echo "✅ Conflict detection complete"
echo ""
echo "🔧 TROUBLESHOOTING TIPS:"
echo "1. Verify ARP resolution first (priority 100 rules)"
echo "2. Check flow counters with: sudo ovs-ofctl dump-flows <switch>"
echo "3. Use tcpdump to trace packet paths"