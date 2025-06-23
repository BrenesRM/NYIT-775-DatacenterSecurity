#!/bin/bash
# Red Slice Debug and Fix Script

# Check if the slice exists and remove it if it does
if fvctl -f pwd list-slices | grep -q Red; then
  echo "Removing existing Red slice..."
  fvctl -f pwd remove-slice Red
fi

# Add the slice with correct protocol
echo "Creating Red slice..."
fvctl -f pwd add-slice Red tcp:127.0.0.1:4000 admin@Red
sleep 2

# Debugging Info
echo "=== Red Slice Debugging ==="
echo "1. Checking FlowVisor switch connections:"
fvctl -f pwd list-datapaths

echo ""
echo "2. Checking Red slice information:"
fvctl -f pwd list-slice-info Red

echo ""
echo "3. Current Red flowspaces:"
fvctl -f pwd list-flowspace | grep Red

echo ""
echo "=== Potential Fix: Adding broader flowspace rules ==="
echo "The issue might be that we need more comprehensive flowspace coverage."
echo "Adding broader rules for Red slice..."

# Remove existing Red flowspaces (ignore errors)
echo "Removing existing Red flowspaces..."
for fs in Red_E3_h8 Red_E3_h9 Red_A2_1 Red_A2_2 Red_C4_1 Red_C4_2 Red_A5_1 Red_A5_2 Red_E4_h11 Red_E4_h12; do
  echo "Trying to remove flowspace $fs..."
  fvctl -f pwd remove-flowspace $fs 2>/dev/null
  sleep 0.1
done

echo ""
echo "Adding broader flowspace rules..."

# E3 Switch
fvctl -f pwd add-flowspace Red_E3_all 0000000000000003 1 nw_src=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_E3_all2 0000000000000003 1 nw_src=10.0.0.9 Red=7

# A2 Switch
fvctl -f pwd add-flowspace Red_A2_all 0000000000000002 1 nw_src=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A2_all2 0000000000000002 1 nw_src=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_A2_all3 0000000000000002 1 nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_A2_all4 0000000000000002 1 nw_dst=10.0.0.9 Red=7

# C4 Switch
fvctl -f pwd add-flowspace Red_C4_all 0000000000000004 1 nw_src=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_C4_all2 0000000000000004 1 nw_src=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_C4_all3 0000000000000004 1 nw_src=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_C4_all4 0000000000000004 1 nw_src=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_C4_all5 0000000000000004 1 nw_dst=10.0.0.8 Red=7
fvctl -f pwd add-flowspace Red_C4_all6 0000000000000004 1 nw_dst=10.0.0.9 Red=7
fvctl -f pwd add-flowspace Red_C4_all7 0000000000000004 1 nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_C4_all8 0000000000000004 1 nw_dst=10.0.0.12 Red=7

# A5 Switch
fvctl -f pwd add-flowspace Red_A5_all 0000000000000005 1 nw_src=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A5_all2 0000000000000005 1 nw_src=10.0.0.12 Red=7
fvctl -f pwd add-flowspace Red_A5_all3 0000000000000005 1 nw_dst=10.0.0.11 Red=7
fvctl -f pwd add-flowspace Red_A5_all4 0000000000000005 1 nw_dst=10.0.0.12 Red=7

echo ""
echo "=== Verification ==="
echo "New flowspace configuration:"
fvctl -f pwd list-flowspace | grep Red

echo ""
echo "=== Testing Commands ==="
echo "Now try these tests in Mininet:"
echo "1. h8 ping -c 3 h9"
echo "2. h11 ping -c 3 h12"
echo "3. h8 ping -c 3 h11"
echo ""
echo "If still not working, check:"
echo "1. POX controller logs for switch connections"
echo "2. FlowVisor logs: tail -f /var/log/flowvisor/flowvisor.log"
