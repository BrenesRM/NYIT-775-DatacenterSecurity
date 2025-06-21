NYIT-775 Data Center Security - Assignment 2
Fat-Tree Topology Simulation with Mininet
This repository contains the implementation of a custom Fat-Tree topology for Mininet, designed for NYIT INCS 775 - Data Center Security (Assignment 2). The project demonstrates network slicing and connectivity testing in a multi-controller environment.

📌 Project Overview
The Fat-Tree topology is a scalable data center network architecture that provides high bisection bandwidth and redundancy. This implementation includes:

4-pod Fat-Tree with core, aggregation, and edge switches.

48 hosts distributed across edge switches.

Multiple OpenFlow controllers for network slicing (FlowVisor compatibility).

Bandwidth and delay configurations for realistic link behavior.

Slice-based connectivity testing to validate network segmentation.

📂 Repository Structure
File	Description
Custom_Fat-Tree.py	Main Fat-Tree topology implementation with slicing support.
Works_Custom_Fat-Tree.py	Simplified Fat-Tree topology (minimal version).
⚙️ Setup & Execution
Prerequisites
Mininet (sudo apt-get install mininet)

Open vSwitch (sudo apt-get install openvswitch-switch)

Python 3

Running the Topology
Run the main Fat-Tree topology (with slicing):

bash
sudo python3 Custom_Fat-Tree.py
This will start Mininet with the full Fat-Tree topology and multiple controllers.

Use the Mininet CLI to test connectivity (ping, iperf, etc.).

Run the simplified version (minimal setup):

bash
sudo mn --custom Works_Custom_Fat-Tree.py --topo mytopo
This version does not include slicing but provides a basic Fat-Tree structure.

🔍 Features
1. Topology Details
Core Switches: C1-C8

Aggregation Switches: A1-A12

Edge Switches: E1-E16

Hosts: h1-h48 (3 per edge switch)

2. Network Slicing
Red Slice: h8, h9, h11, h12

Green Slice: h28-h36

Blue Slice: h31-h36

Pink Slice: h34, h35, h36, h45

3. Link Configuration
Host-to-Edge: 100 Mbps, 1ms delay

Inter-Switch Links: 1 Gbps, 1ms delay

4. Connectivity Testing
The script includes automated ping tests between hosts in the same slice.

📊 Expected Output
After running Custom_Fat-Tree.py, you should see:

A list of all switches and hosts with their DPIDs, IPs, and MACs.

Slice-based host groupings.

Ping test results for intra-slice communication.

Mininet CLI for manual testing.

📜 License
This project is part of an academic assignment and is free to use for educational purposes.

📧 Contact
For questions or improvements, contact:

Rafael Brenes | GitHub

🎯 Key Takeaways
✅ Learn Fat-Tree topology structure.
✅ Understand network slicing with multiple controllers.
✅ Test connectivity in segmented networks.
