#!/bin/bash
# FlowVisor slice creation script for Assignment 2

# Create network slices with controller ports
fvctl -f pwd add-slice Red tcp:127.0.0.1:4000 admin@Red
fvctl -f pwd add-slice Green tcp:127.0.0.1:5000 admin@Green
fvctl -f pwd add-slice Blue tcp:127.0.0.1:6000 admin@Blue
fvctl -f pwd add-slice Pink tcp:127.0.0.1:7000 admin@Pink

# Check slice status and info
fvctl -f pwd list-slices
fvctl -f pwd list-slice-info Red
fvctl -f pwd list-slice-info Green
fvctl -f pwd list-slice-info Blue
fvctl -f pwd list-slice-info Pink
