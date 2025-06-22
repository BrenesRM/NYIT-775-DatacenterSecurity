#!/bin/bash

echo "🔍 Checking FlowVisor status..."
sudo /etc/init.d/flowvisor status
echo

echo "🔍 Verifying controller port (6633)..."
sudo netstat -tulnp | grep 6633
echo

echo "🔍 Listing connected datapaths (switches)..."
fvctl -f pwd list-datapaths
echo

echo "🔍 Listing configured slices..."
fvctl -f pwd list-slices
echo

echo "🔍 Listing flowspace rules..."
fvctl -f pwd list-flowspace
echo

echo "🔍 Getting FlowVisor config..."
fvctl -f pwd get-config | jq .
