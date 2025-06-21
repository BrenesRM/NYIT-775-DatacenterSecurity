#!/usr/bin/env python3
"""
FlowVisor Slice Validation and Testing Script
INCS 775 - Data Center Security Assignment 2

This script validates slice isolation and tests connectivity
within and between network slices.
"""

import subprocess
import time
import json
import sys
import os
from datetime import datetime
import threading
import socket

class SliceValidator:
    """Validates FlowVisor slice configuration and connectivity"""
    
    def __init__(self, output_dir="./validation_outputs"):
        self.output_dir = output_dir
        self.results = {}
        self.slice_definitions = {
            'Red': {
                'hosts': ['h8', 'h9', 'h11', 'h12'],
                'switches': ['E3', 'A2', 'C4', 'A5', 'E4'],
                'controller_port': 4000,
                'expected_ip_ranges': ['10.0.3.1', '10.0.3.2', '10.0.4.2', '10.0.4.3']
            },
            'Green': {
                'hosts': ['h28', 'h29', 'h30', 'h31', 'h32', 'h33', 'h34', 'h35', 'h36'],
                'switches': ['E10', 'E11', 'E12', 'A10', 'A11', 'A12'],
                'controller_port': 5000,
                'expected_ip_ranges': ['10.0.10.1', '10.0.10.2', '10.0.10.3', 
                                     '10.0.11.1', '10.0.11.2', '10.0.11.3',
                                     '10.0.12.1', '10.0.12.2', '10.0.12.3']
            },
            'Blue': {
                'hosts': ['h31', 'h32', 'h33', 'h34', 'h35', 'h36'],
                'switches': ['E11', 'E12', 'A11', 'A12'],
                'controller_port': 6000,
                'expected_ip_ranges': ['10.0.11.1', '10.0.11.2', '10.0.11.3',
                                     '10.0.12.1', '10.0.12.2', '10.0.12.3']
            },
            'Pink': {
                'hosts': ['h34', 'h35', 'h36', 'h45'],
                'switches': ['E12', 'A12', 'C7', 'A15', 'E15'],
                'controller_port': 7000,
                'expected_ip_ranges': ['10.0.12.1', '10.0.12.2', '10.0.12.3', '10.0.15.3']
            }
        }
        
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Initialize results structure
        for slice_name in self.slice_definitions.keys():
            self.results[slice_name] = {
                'slice_exists': False,
                'controller_reachable': False,
                'intra_slice_connectivity': {},
                'inter_slice_isolation': {},
                'flowspace_rules': 0,
                'bandwidth_tests': {}
            }
    
    def log_message(self, message, level="INFO"):
        """Log message with timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] {level}: {message}"
        print(log_entry)
        
        # Also write to log file
        log_file = os.path.join(self.output_dir, "validation.log")
        with open(log_file, "a") as f:
            f.write(log_entry + "\n")
    
    def run_command(self, command, timeout=30):
        """Execute command and return result"""
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return result.returncode == 0, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            self.log_message(f"Command timed out: {command}", "ERROR")
            return False, "", "Command timed out"
        except Exception as e:
            self.log_message(f"Command failed: {command}, Error: {str(e)}", "ERROR")
            return False, "", str(e)
    
    def check_mininet_running(self):
        """Check if Mininet is running"""
        success, stdout, stderr = self.run_command("sudo mn --version")
        if success:
            self.log_message("Mininet is available")
            return True
        else:
            self.log_message("Mininet is not available or not running", "ERROR")
            return False
    
    def check_flowvisor_running(self):
        """Check if FlowVisor is running"""
        success, stdout, stderr = self.run_command("pgrep -f flowvisor")
        if success:
            self.log_message("FlowVisor is running")
            return True
        else:
            self.log_message("FlowVisor is not running", "ERROR")
            return False
    
    def check_slice_exists(self, slice_name):
        """Check if a slice exists in FlowVisor"""
        success, stdout, stderr = self.run_command(
            f"fvctl -f /etc/flowvisor/passwd list-slices | grep '{slice_name}'"
        )
        
        exists = success and slice_name in stdout
        self.results[slice_name]['slice_exists'] = exists
        
        if exists:
            self.log_message(f"Slice {slice_name} exists")
        else:
            self.log_message(f"Slice {slice_name} does not exist", "WARNING")
        
        return exists
    
    def check_controller_connectivity(self, slice_name):
        """Check if controller is reachable on specified port"""
        port = self.slice_definitions[slice_name]['controller_port']
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex(('127.0.0.1', port))
            sock.close()
            
            reachable = result == 0
            self.results[slice_name]['controller_reachable'] = reachable
            
            if reachable:
                self.log_message(f"Controller for {slice_name} is reachable on port {port}")
            else:
                self.log_message(f"Controller for {slice_name} is NOT reachable on port {port}", "WARNING")
            
            return reachable
            
        except Exception as e:
            self.log_message(f"Error checking controller connectivity for {slice_name}: {str(e)}", "ERROR")
            self.results[slice_name]['controller_reachable'] = False
            return False
    
    def count_flowspace_rules(self, slice_name):
        """Count flowspace rules for a slice"""
        success, stdout, stderr = self.run_command(
            f"fvctl -f /etc/flowvisor/passwd list-flowspace | grep '{slice_name}' | wc -l"
        )
        
        if success:
            try:
                rule_count = int(stdout.strip())
                self.results[slice_name]['flowspace_rules'] = rule_count
                self.log_message(f"Slice {slice_name} has {rule_count} flowspace rules")
                return rule_count
            except ValueError:
                self.log_message(f"Could not parse rule count for {slice_name}", "WARNING")
                return 0
        else:
            self.log_message(f"Failed to count flowspace rules for {slice_name}", "ERROR")
            return 0
    
    def test_ping_connectivity(self, src_host, dst_host, expected_result=True):
        """Test ping connectivity between two hosts"""
        # Note: This requires Mininet to be running with the topology
        command = f"sudo mn --test=none -c && echo 'pingall {src_host} {dst_host}' | sudo mn"
        
        # Simplified ping test - in real implementation, you would need
        # to access the Mininet CLI programmatically
        success, stdout, stderr = self.run_command(
            f"timeout 10 ping -c 3 -W 1 {dst_host} 2>/dev/null || echo 'FAILED'"
        )
        
        # This is a placeholder - actual implementation would require
        # integration with Mininet's API
        ping_successful = "FAILED" not in stdout and success
        
        result = {
            'success': ping_successful,
            'expected': expected_result,
            'correct': ping_successful == expected_result
        }
        
        status = "✓" if result['correct'] else "✗"
        self.log_message(f"{status} Ping {src_host} -> {dst_host}: {'SUCCESS' if ping_successful else 'FAILED'} (Expected: {'SUCCESS' if expected_result else 'FAILED'})")
        
        return result
    
    def test_intra_slice_connectivity(self, slice_name):
        """Test connectivity within a slice"""
        hosts = self.slice_definitions[slice_name]['hosts']
        connectivity_results = {}
        
        self.log_message(f"Testing intra-slice connectivity for {slice_name}")
        
        # Test all host pairs within the slice
        for i, host1 in enumerate(hosts):
            for host2 in hosts[i+1:]:
                pair_key = f"{host1}-{host2}"
                # All hosts within a slice should be able to communicate
                result = self.test_ping_connectivity(host1, host2, expected_result=True)
                connectivity_results[pair_key] = result
        
        self.results[slice_name]['intra_slice_connectivity'] = connectivity_results
        
        # Calculate success rate
        total_tests = len(connectivity_results)
        successful_tests = sum(1 for r in connectivity_results.values() if r['