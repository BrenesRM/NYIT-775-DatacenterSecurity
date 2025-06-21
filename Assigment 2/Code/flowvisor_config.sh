#!/bin/bash

# FlowVisor Configuration Script for Network Slicing
# INCS 775 - Data Center Security Assignment 2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# FlowVisor password (change as needed)
FV_PASS="fvadmin"

echo -e "${YELLOW}=== FlowVisor Configuration Script ===${NC}"
echo "Configuring network slices for Data Center Security Lab"
echo

# Function to check if FlowVisor is running
check_flowvisor() {
    if ! pgrep -f "flowvisor" > /dev/null; then
        echo -e "${RED}Error: FlowVisor is not running!${NC}"
        echo "Please start FlowVisor first:"
        echo "sudo java -jar /opt/flowvisor/dist/flowvisor.jar /etc/flowvisor/config.json"
        exit 1
    fi
    echo -e "${GREEN}FlowVisor is running${NC}"
}

# Function to create a slice
create_slice() {
    local slice_name=$1
    local controller_url=$2
    local admin_contact=$3
    local slice_pass=$4
    
    echo -e "${YELLOW}Creating slice: $slice_name${NC}"
    
    fvctl -f /etc/flowvisor/passwd add-slice "$slice_name" "$controller_url" "$admin_contact"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully created slice: $slice_name${NC}"
        
        # Set slice password
        echo "$slice_pass" | fvctl -f /etc/flowvisor/passwd set-slice-passwd "$slice_name"
        
        # Set slice contact email
        fvctl -f /etc/flowvisor/passwd set-slice-contact-email "$slice_name" "$admin_contact"
        
    else
        echo -e "${RED}Failed to create slice: $slice_name${NC}"
    fi
}

# Function to create flowspace rules
create_flowspace() {
    local slice_name=$1
    local switch_dpid=$2
    local priority=$3
    local match_string=$4
    local rule_name=$5
    
    echo "  Adding flowspace rule: $rule_name for $slice_name"
    
    fvctl -f /etc/flowvisor/passwd add-flowspace "$switch_dpid" "$priority" "$match_string" "$slice_name"
    
    if [ $? -eq 0 ]; then
        echo -e "    ${GREEN}✓${NC} Flowspace rule added successfully"
    else
        echo -e "    ${RED}✗${NC} Failed to add flowspace rule"
    fi
}

# Function to configure Red Slice
configure_red_slice() {
    echo -e "${RED}=== Configuring Red Slice ===${NC}"
    echo "Hosts: h8, h9, h11, h12"
    echo "Switches: E3, A2, C4, A5, E4"
    echo "Controller: TCP port 4000"
    echo
    
    # Create Red slice
    create_slice "Red" "tcp:127.0.0.1:4000" "red@datacenter.lab" "redpass"
    
    # Define switch DPIDs for Red slice
    declare -A red_switches=(
        ["E3"]="00:00:00:00:02:03"
        ["A2"]="00:00:00:00:01:02"
        ["C4"]="00:00:00:00:00:04"
        ["A5"]="00:00:00:00:01:05"
        ["E4"]="00:00:00:00:02:04"
    )
    
    # Add flowspace rules for Red slice switches
    priority=100
    for switch in "${!red_switches[@]}"; do
        dpid="${red_switches[$switch]}"
        
        # Allow all traffic on these switches for Red slice hosts
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.1,nw_dst=10.0.3.2" "${switch}_h8_h9"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.1,nw_dst=10.0.4.2" "${switch}_h8_h11"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.1,nw_dst=10.0.4.3" "${switch}_h8_h12"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.2,nw_dst=10.0.4.2" "${switch}_h9_h11"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.2,nw_dst=10.0.4.3" "${switch}_h9_h12"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.2,nw_dst=10.0.4.3" "${switch}_h11_h12"
        
        # Add reverse direction rules
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.3.2,nw_dst=10.0.3.1" "${switch}_h9_h8"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.2,nw_dst=10.0.3.1" "${switch}_h11_h8"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.3,nw_dst=10.0.3.1" "${switch}_h12_h8"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.2,nw_dst=10.0.3.2" "${switch}_h11_h9"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.3,nw_dst=10.0.3.2" "${switch}_h12_h9"
        create_flowspace "Red" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.4.3,nw_dst=10.0.4.2" "${switch}_h12_h11"
        
        # ARP traffic
        create_flowspace "Red" "$dpid" "$((priority-10))" "dl_type=0x0806" "${switch}_arp"
    done
    
    echo -e "${RED}Red slice configuration completed${NC}"
    echo
}

# Function to configure Green Slice
configure_green_slice() {
    echo -e "${GREEN}=== Configuring Green Slice ===${NC}"
    echo "Hosts: h28, h29, h30, h31, h32, h33, h34, h35, h36"
    echo "Switches: E10, E11, E12, A10, A11, A12"
    echo "Controller: TCP port 5000"
    echo
    
    # Create Green slice
    create_slice "Green" "tcp:127.0.0.1:5000" "green@datacenter.lab" "greenpass"
    
    # Define switch DPIDs for Green slice
    declare -A green_switches=(
        ["E10"]="00:00:00:00:02:10"
        ["E11"]="00:00:00:00:02:11"
        ["E12"]="00:00:00:00:02:12"
        ["A10"]="00:00:00:00:01:10"
        ["A11"]="00:00:00:00:01:11"
        ["A12"]="00:00:00:00:01:12"
    )
    
    # Add flowspace rules for Green slice
    priority=90
    for switch in "${!green_switches[@]}"; do
        dpid="${green_switches[$switch]}"
        
        # Green slice hosts are h28-h36 (subnet 10.0.10.x, 10.0.11.x, 10.0.12.x)
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.10.0/24" "${switch}_green_subnet10"
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.0/24" "${switch}_green_subnet11"
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.0/24" "${switch}_green_subnet12"
        
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_dst=10.0.10.0/24" "${switch}_green_dst10"
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_dst=10.0.11.0/24" "${switch}_green_dst11"
        create_flowspace "Green" "$dpid" "$priority" "dl_type=0x0800,nw_dst=10.0.12.0/24" "${switch}_green_dst12"
        
        # ARP traffic
        create_flowspace "Green" "$dpid" "$((priority-10))" "dl_type=0x0806" "${switch}_green_arp"
    done
    
    echo -e "${GREEN}Green slice configuration completed${NC}"
    echo
}

# Function to configure Blue Slice
configure_blue_slice() {
    echo -e "${BLUE}=== Configuring Blue Slice ===${NC}"
    echo "Hosts: h31, h32, h33, h34, h35, h36"
    echo "Switches: E11, E12, A11, A12"
    echo "Controller: TCP port 6000"
    echo
    
    # Create Blue slice
    create_slice "Blue" "tcp:127.0.0.1:6000" "blue@datacenter.lab" "bluepass"
    
    # Define switch DPIDs for Blue slice
    declare -A blue_switches=(
        ["E11"]="00:00:00:00:02:11"
        ["E12"]="00:00:00:00:02:12"
        ["A11"]="00:00:00:00:01:11"
        ["A12"]="00:00:00:00:01:12"
    )
    
    # Add flowspace rules for Blue slice
    priority=80
    for switch in "${!blue_switches[@]}"; do
        dpid="${blue_switches[$switch]}"
        
        # Blue slice hosts are h31-h36 (specific IPs)
        create_flowspace "Blue" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.1,nw_dst=10.0.11.2" "${switch}_blue_h31_h32"
        create_flowspace "Blue" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.1,nw_dst=10.0.11.3" "${switch}_blue_h31_h33"
        create_flowspace "Blue" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.1,nw_dst=10.0.12.1" "${switch}_blue_h31_h34"
        create_flowspace "Blue" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.1,nw_dst=10.0.12.2" "${switch}_blue_h31_h35"
        create_flowspace "Blue" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.11.1,nw_dst=10.0.12.3" "${switch}_blue_h31_h36"
        
        # Add more specific rules for other host pairs...
        # (Similar pattern for all combinations)
        
        # ARP traffic
        create_flowspace "Blue" "$dpid" "$((priority-10))" "dl_type=0x0806" "${switch}_blue_arp"
    done
    
    echo -e "${BLUE}Blue slice configuration completed${NC}"
    echo
}

# Function to configure Pink Slice
configure_pink_slice() {
    echo -e "${PINK}=== Configuring Pink Slice ===${NC}"
    echo "Hosts: h34, h35, h36, h45"
    echo "Switches: E12, A12, C7, A15, E15"
    echo "Controller: TCP port 7000"
    echo
    
    # Create Pink slice
    create_slice "Pink" "tcp:127.0.0.1:7000" "pink@datacenter.lab" "pinkpass"
    
    # Define switch DPIDs for Pink slice
    declare -A pink_switches=(
        ["E12"]="00:00:00:00:02:12"
        ["A12"]="00:00:00:00:01:12"
        ["C7"]="00:00:00:00:00:07"
        ["A15"]="00:00:00:00:01:15"
        ["E15"]="00:00:00:00:02:15"
    )
    
    # Add flowspace rules for Pink slice
    priority=70
    for switch in "${!pink_switches[@]}"; do
        dpid="${pink_switches[$switch]}"
        
        # Pink slice hosts are h34, h35, h36, h45
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.1,nw_dst=10.0.12.2" "${switch}_pink_h34_h35"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.1,nw_dst=10.0.12.3" "${switch}_pink_h34_h36"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.1,nw_dst=10.0.15.3" "${switch}_pink_h34_h45"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.2,nw_dst=10.0.12.3" "${switch}_pink_h35_h36"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.2,nw_dst=10.0.15.3" "${switch}_pink_h35_h45"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.3,nw_dst=10.0.15.3" "${switch}_pink_h36_h45"
        
        # Reverse direction rules
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.2,nw_dst=10.0.12.1" "${switch}_pink_h35_h34"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.3,nw_dst=10.0.12.1" "${switch}_pink_h36_h34"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.15.3,nw_dst=10.0.12.1" "${switch}_pink_h45_h34"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.12.3,nw_dst=10.0.12.2" "${switch}_pink_h36_h35"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.15.3,nw_dst=10.0.12.2" "${switch}_pink_h45_h35"
        create_flowspace "Pink" "$dpid" "$priority" "dl_type=0x0800,nw_src=10.0.15.3,nw_dst=10.0.12.3" "${switch}_pink_h45_h36"
        
        # ARP traffic
        create_flowspace "Pink" "$dpid" "$((priority-10))" "dl_type=0x0806" "${switch}_pink_arp"
    done
    
    echo -e "${PINK}Pink slice configuration completed${NC}"
    echo
}

# Function to display slice summary
display_slice_summary() {
    echo -e "${YELLOW}=== Slice Configuration Summary ===${NC}"
    echo
    echo -e "${RED}Red Slice:${NC}"
    echo "  Controller: tcp:127.0.0.1:4000"
    echo "  Hosts: h8, h9, h11, h12"
    echo "  Switches: E3, A2, C4, A5, E4"
    echo
    echo -e "${GREEN}Green Slice:${NC}"
    echo "  Controller: tcp:127.0.0.1:5000"
    echo "  Hosts: h28, h29, h30, h31, h32, h33, h34, h35, h36"
    echo "  Switches: E10, E11, E12, A10, A11, A12"
    echo
    echo -e "${BLUE}Blue Slice:${NC}"
    echo "  Controller: tcp:127.0.0.1:6000"
    echo "  Hosts: h31, h32, h33, h34, h35, h36"
    echo "  Switches: E11, E12, A11, A12"
    echo
    echo -e "${PINK}Pink Slice:${NC}"
    echo "  Controller: tcp:127.0.0.1:7000"
    echo "  Hosts: h34, h35, h36, h45"
    echo "  Switches: E12, A12, C7, A15, E15"
    echo
}

# Function to verify slice creation
verify_slices() {
    echo -e "${YELLOW}=== Verifying Slice Creation ===${NC}"
    
    slices=("Red" "Green" "Blue" "Pink")
    
    for slice in "${slices[@]}"; do
        echo "Checking slice: $slice"
        if fvctl -f /etc/flowvisor/passwd list-slices | grep -q "$slice"; then
            echo -e "  ${GREEN}✓${NC} $slice slice exists"
        else
            echo -e "  ${RED}✗${NC} $slice slice not found"
        fi
    done
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -c, --configure     Configure all slices"
    echo "  -v, --verify        Verify slice configuration"
    echo "  -s, --summary       Display slice summary"
    echo "  -r, --red           Configure Red slice only"
    echo "  -g, --green         Configure Green slice only"
    echo "  -b, --blue          Configure Blue slice only"
    echo "  -p, --pink          Configure Pink slice only"
    echo "  -h, --help          Show this help message"
    echo
}

# Main execution
main() {
    case "$1" in
        -c|--configure)
            check_flowvisor
            configure_red_slice
            configure_green_slice
            configure_blue_slice
            configure_pink_slice
            verify_slices
            display_slice_summary
            ;;
        -v|--verify)
            verify_slices
            ;;
        -s|--summary)
            display_slice_summary
            ;;
        -r|--red)
            check_flowvisor
            configure_red_slice
            ;;
        -g|--green)
            check_flowvisor
            configure_green_slice
            ;;
        -b|--blue)
            check_flowvisor
            configure_blue_slice
            ;;
        -p|--pink)
            check_flowvisor
            configure_pink_slice
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo -e "${YELLOW}FlowVisor Configuration Script${NC}"
            echo "Run with --help for usage options"
            echo
            show_usage
            ;;
    esac
}

# Execute main function with all arguments
main "$@"