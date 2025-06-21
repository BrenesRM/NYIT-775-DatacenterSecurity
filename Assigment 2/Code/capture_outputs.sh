#!/bin/bash

# FlowVisor Output Capture Script
# INCS 775 - Data Center Security Assignment 2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PINK='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PASSWD_FILE="/etc/flowvisor/passwd"
OUTPUT_DIR="./flowvisor_outputs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$OUTPUT_DIR/capture_log_$TIMESTAMP.txt"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${YELLOW}=== FlowVisor Output Capture Script ===${NC}" | tee "$LOG_FILE"
echo "Capturing FlowVisor slice information and flowspace data" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Function to check if FlowVisor is running
check_flowvisor() {
    echo "Checking FlowVisor status..." | tee -a "$LOG_FILE"
    
    if ! pgrep -f "flowvisor" > /dev/null; then
        echo -e "${RED}Error: FlowVisor is not running!${NC}" | tee -a "$LOG_FILE"
        echo "Please start FlowVisor first:" | tee -a "$LOG_FILE"
        echo "sudo java -jar /opt/flowvisor/dist/flowvisor.jar /etc/flowvisor/config.json" | tee -a "$LOG_FILE"
        exit 1
    fi
    
    echo -e "${GREEN}FlowVisor is running${NC}" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Function to check if slice exists
check_slice_exists() {
    local slice_name=$1
    
    if fvctl -f "$PASSWD_FILE" list-slices 2>/dev/null | grep -q "^$slice_name"; then
        return 0
    else
        return 1
    fi
}

# Function to capture slice information
capture_slice_info() {
    local slice_name=$1
    local output_file="$OUTPUT_DIR/${slice_name}"
    
    echo -e "${YELLOW}Capturing slice info for: $slice_name${NC}" | tee -a "$LOG_FILE"
    
    if check_slice_exists "$slice_name"; then
        # Execute the command and capture output
        if fvctl -f "$PASSWD_FILE" list-slice-info "$slice_name" &>"$output_file"; then
            echo -e "${GREEN}✓${NC} Successfully captured $slice_name slice info to $output_file" | tee -a "$LOG_FILE"
            
            # Display first few lines for verification
            echo "Preview of $slice_name slice info:" | tee -a "$LOG_FILE"
            head -10 "$output_file" | sed 's/^/  /' | tee -a "$LOG_FILE"
            echo | tee -a "$LOG_FILE"
        else
            echo -e "${RED}✗${NC} Failed to capture $slice_name slice info" | tee -a "$LOG_FILE"
        fi
    else
        echo -e "${RED}✗${NC} Slice $slice_name does not exist" | tee -a "$LOG_FILE"
        echo "Available slices:" | tee -a "$LOG_FILE"
        fvctl -f "$PASSWD_FILE" list-slices 2>/dev/null | sed 's/^/  /' | tee -a "$LOG_FILE"
        echo | tee -a "$LOG_FILE"
    fi
}

# Function to capture flowspace for a specific slice
capture_slice_flowspace() {
    local slice_name=$1
    local output_file="$OUTPUT_DIR/${slice_name}_FS"
    
    echo -e "${YELLOW}Capturing flowspace for: $slice_name${NC}" | tee -a "$LOG_FILE"
    
    if check_slice_exists "$slice_name"; then
        # Get all flowspace rules and filter for this slice
        if fvctl -f "$PASSWD_FILE" list-flowspace 2>/dev/null | grep "$slice_name" > "$output_file"; then
            if [ -s "$output_file" ]; then
                echo -e "${GREEN}✓${NC} Successfully captured $slice_name flowspace to $output_file" | tee -a "$LOG_FILE"
                
                # Count rules
                rule_count=$(wc -l < "$output_file")
                echo "  Found $rule_count flowspace rules for $slice_name" | tee -a "$LOG_FILE"
                
                # Display first few rules for verification
                echo "Preview of $slice_name flowspace rules:" | tee -a "$LOG_FILE"
                head -5 "$output_file" | sed 's/^/  /' | tee -a "$LOG_FILE"
                echo | tee -a "$LOG_FILE"
            else
                echo -e "${RED}✗${NC} No flowspace rules found for $slice_name" | tee -a "$LOG_FILE"
            fi
        else
            echo -e "${RED}✗${NC} Failed to capture $slice_name flowspace" | tee -a "$LOG_FILE"
        fi
    else
        echo -e "${RED}✗${NC} Slice $slice_name does not exist" | tee -a "$LOG_FILE"
    fi
}

# Function to capture complete flowspace
capture_complete_flowspace() {
    local output_file="$OUTPUT_DIR/flowspace"
    
    echo -e "${YELLOW}Capturing complete flowspace information${NC}" | tee -a "$LOG_FILE"
    
    if fvctl -f "$PASSWD_FILE" list-flowspace &>"$output_file"; then
        echo -e "${GREEN}✓${NC} Successfully captured complete flowspace to $output_file" | tee -a "$LOG_FILE"
        
        # Count total rules
        rule_count=$(grep -c "^" "$output_file" 2>/dev/null || echo "0")
        echo "  Total flowspace rules: $rule_count" | tee -a "$LOG_FILE"
        
        # Show summary by slice
        echo "Flowspace rules by slice:" | tee -a "$LOG_FILE"
        for slice in Red Green Blue Pink; do
            slice_rules=$(grep -c "$slice" "$output_file" 2>/dev/null || echo "0")
            echo "  $slice: $slice_rules rules" | tee -a "$LOG_FILE"
        done
        echo | tee -a "$LOG_FILE"
        
    else
        echo -e "${RED}✗${NC} Failed to capture complete flowspace" | tee -a "$LOG_FILE"
    fi
}

# Function to verify slice connectivity
verify_slice_connectivity() {
    echo -e "${YELLOW}Verifying slice connectivity status${NC}" | tee -a "$LOG_FILE"
    
    local connectivity_file="$OUTPUT_DIR/connectivity_status.txt"
    
    {
        echo "=== Slice Connectivity Verification ==="
        echo "Timestamp: $(date)"
        echo
        
        # Check each slice status
        for slice in Red Green Blue Pink; do
            echo "=== $slice Slice Status ==="
            
            if check_slice_exists "$slice"; then
                echo "✓ Slice exists"
                
                # Get slice controller info
                controller_info=$(fvctl -f "$PASSWD_FILE" list-slice-info "$slice" 2>/dev/null | grep -E "(controller|contact|passwd)")
                if [ -n "$controller_info" ]; then
                    echo "Controller Information:"
                    echo "$controller_info" | sed 's/^/  /'
                else
                    echo "⚠ No controller information available"
                fi
                
                # Count flowspace rules
                rule_count=$(fvctl -f "$PASSWD_FILE" list-flowspace 2>/dev/null | grep -c "$slice" || echo "0")
                echo "Flowspace rules: $rule_count"
                
            else
                echo "✗ Slice does not exist"
            fi
            echo
        done
        
        echo "=== Overall System Status ==="
        echo "FlowVisor process: $(pgrep -f flowvisor > /dev/null && echo "Running" || echo "Not running")"
        echo "Total slices: $(fvctl -f "$PASSWD_FILE" list-slices 2>/dev/null | wc -l || echo "0")"
        echo "Total flowspace rules: $(fvctl -f "$PASSWD_FILE" list-flowspace 2>/dev/null | wc -l || echo "0")"
        
    } > "$connectivity_file"
    
    echo -e "${GREEN}✓${NC} Connectivity status saved to $connectivity_file" | tee -a "$LOG_FILE"
    
    # Display summary
    echo "Connectivity Summary:" | tee -a "$LOG_FILE"
    grep -E "(✓|✗|⚠)" "$connectivity_file" | sed 's/^/  /' | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Function to create assignment submission summary
create_submission_summary() {
    local summary_file="$OUTPUT_DIR/submission_summary.txt"
    
    echo -e "${YELLOW}Creating submission summary${NC}" | tee -a "$LOG_FILE"
    
    {
        echo "=== INCS 775 Assignment 2 Submission Summary ==="
        echo "Student: [Your Name Here]"
        echo "Date: $(date)"
        echo
        
        echo "=== Required Files Status ==="
        
        # Check for required files
        files_to_check=("Red" "Green" "Blue" "Pink" "Red_FS" "Green_FS" "Blue_FS" "Pink_FS" "flowspace")
        
        for file in "${files_to_check[@]}"; do
            if [ -f "$OUTPUT_DIR/$file" ]; then
                size=$(stat -f%z "$OUTPUT_DIR/$file" 2>/dev/null || stat -c%s "$OUTPUT_DIR/$file" 2>/dev/null || echo "unknown")
                echo "✓ $file (${size} bytes)"
            else
                echo "✗ $file (MISSING)"
            fi
        done
        
        echo
        echo "=== Slice Configuration Summary ==="
        echo "Red Slice (Port 4000): h8, h9, h11, h12"
        echo "Green Slice (Port 5000): h28-h36"
        echo "Blue Slice (Port 6000): h31-h36"
        echo "Pink Slice (Port 7000): h34, h35, h36, h45"
        
        echo
        echo "=== Files Generated ==="
        ls -la "$OUTPUT_DIR" | grep -v "^total" | sed 's/^/  /'
        
    } > "$summary_file"
    
    echo -e "${GREEN}✓${NC} Submission summary created: $summary_file" | tee -a "$LOG_FILE"
}

# Function to create zip file for submission
create_submission_zip() {
    local zip_name="lastname_firstname_$(date +%Y%m%d).zip"
    local temp_dir="submission_temp"
    
    echo -e "${YELLOW}Creating submission zip file${NC}" | tee -a "$LOG_FILE"
    
    # Create temporary directory structure
    mkdir -p "$temp_dir"
    
    # Copy required files
    cp "$OUTPUT_DIR"/{Red,Green,Blue,Pink,Red_FS,Green_FS,Blue_FS,Pink_FS,flowspace} "$temp_dir/" 2>/dev/null
    
    # Copy the topology script if it exists
    if [ -f "Custom_Fat-Tree.py" ]; then
        cp "Custom_Fat-Tree.py" "$temp_dir/"
        echo "✓ Included Custom_Fat-Tree.py" | tee -a "$LOG_FILE"
    else
        echo "⚠ Custom_Fat-Tree.py not found in current directory" | tee -a "$LOG_FILE"
    fi
    
    # Create Group_info file template
    cat > "$temp_dir/Group_info" << EOF
Group Members:
Name: [Your Full Name]
Student ID: [Your Student ID]

Name: [Member 2 Full Name]
Student ID: [Member 2 Student ID]

Assignment: INCS 775 Assignment 2 - FlowVisor Network Slicing
Date: $(date)
EOF
    
    # Create the zip file
    if command -v zip > /dev/null; then
        cd "$temp_dir"
        zip -r "../$zip_name" . > /dev/null
        cd ..
        echo -e "${GREEN}✓${NC} Created submission zip: $zip_name" | tee -a "$LOG_FILE"
    else
        echo -e "${RED}✗${NC} zip command not found. Please install zip or create archive manually" | tee -a "$LOG_FILE"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}

# Main execution function
main() {
    echo "Starting FlowVisor output capture process..." | tee -a "$LOG_FILE"
    
    # Check prerequisites
    check_flowvisor
    
    # Capture slice information (5 points each)
    echo -e "${YELLOW}=== Capturing Slice Information (20 points total) ===${NC}" | tee -a "$LOG_FILE"
    capture_slice_info "Red"
    capture_slice_info "Green"
    capture_slice_info "Blue"
    capture_slice_info "Pink"
    
    # Capture flowspace for each slice (15 points each)
    echo -e "${YELLOW}=== Capturing Slice Flowspaces (60 points total) ===${NC}" | tee -a "$LOG_FILE"
    capture_slice_flowspace "Red"
    capture_slice_flowspace "Green"
    capture_slice_flowspace "Blue"
    capture_slice_flowspace "Pink"
    
    # Capture complete flowspace (20 points)
    echo -e "${YELLOW}=== Capturing Complete Flowspace (20 points) ===${NC}" | tee -a "$LOG_FILE"
    capture_complete_flowspace
    
    # Additional verification
    verify_slice_connectivity
    
    # Create submission materials
    create_submission_summary
    create_submission_zip
    
    echo -e "${GREEN}=== Capture Process Complete ===${NC}" | tee -a "$LOG_FILE"
    echo "All outputs saved to: $OUTPUT_DIR" | tee -a "$LOG_FILE"
    echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
    echo
    echo "Next steps:" | tee -a "$LOG_FILE"
    echo "1. Review all generated files in $OUTPUT_DIR" | tee -a "$LOG_FILE"
    echo "2. Update Group_info file with correct information" | tee -a "$LOG_FILE"
    echo "3. Ensure Custom_Fat-Tree.py is in the submission" | tee -a "$LOG_FILE"
    echo "4. Create final zip file for submission" | tee -a "$LOG_FILE"
}

# Execute main function
main "$@"