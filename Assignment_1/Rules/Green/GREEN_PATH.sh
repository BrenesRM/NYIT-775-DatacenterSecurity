#!/bin/bash

# Mininet SDN Flow Configuration - Non-Overlapping Rules
# Priority Strategy: Higher numbers = Higher priority
# 100: ARP (highest)
# 90-99: Core infrastructure rules  
# 50-89: Specific host-to-host paths (differentiated by priority)
# 10-49: General routing rules
# 1: Drop all (lowest)

# Define all switches in the topology
switches=(E1 E2 A1)

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
# Priority 40-49: Backup/Alternative paths
###########################################

###########################################
# GREEN PATH (Priority 80-89): h1 (10.0.0.1) <-> h4 (10.0.0.4)
# Route: h1 -> E1 -> A1 -> E2 -> h4
###########################################

echo "[*] Installing GREEN PATH: h1 <-> h4 (Priority 80-89)..."

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic h1->h4
sudo ovs-ofctl add-flow E1 "priority=200,in_port=1,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:4"
# ARP traffic h4->h1 
sudo ovs-ofctl add-flow E1 "priority=200,in_port=4,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:1"
# IP traffic h1->h4
sudo ovs-ofctl add-flow E1 "priority=200,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:4"
# IP traffic h4->h1
sudo ovs-ofctl add-flow E1 "priority=200,in_port=4,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic E1->E2 (h1->h4)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=1,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:2"
# ARP traffic E2->E1 (h4->h1)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=2,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:1"
# IP traffic E1->E2 (h1->h4)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=1,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:2"
# IP traffic E2->E1 (h4->h1)
sudo ovs-ofctl add-flow A1 "priority=200,in_port=2,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:1"

# GREEN PATH: h1<->h4 (Priority 200)
# ARP traffic A1->h4 (from h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=4,arp,arp_spa=10.0.0.1,arp_tpa=10.0.0.4,actions=output:1"
# ARP traffic h4->A1 (to h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=1,arp,arp_spa=10.0.0.4,arp_tpa=10.0.0.1,actions=output:4"
# IP traffic A1->h4 (from h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=4,ip,nw_src=10.0.0.1,nw_dst=10.0.0.4,actions=output:1"
# IP traffic h4->A1 (to h1)
sudo ovs-ofctl add-flow E2 "priority=200,in_port=1,ip,nw_src=10.0.0.4,nw_dst=10.0.0.1,actions=output:4"



echo "✅ GREEN PATH h1 <-> h4 installed (Priority 85)"

##########################################
# GENERAL ROUTING RULES (Priority 10-39)
##########################################

echo "[*] Installing general routing rules (Priority 10-39)..."

# Default routing for unmatched traffic within same subnet
for switch in E1 E2 A1; do
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
for switch in E1 A1 E2; do
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