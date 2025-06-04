# NYIT-775-DatacenterSecurity
Cource from NYIT - Vancouver


# Mininet Environment Test Script

This script (`mininet_env_test.py`) is a basic Python program designed to help you verify that your Mininet installation and Python environment are correctly set up for network simulations. It creates a minimal network topology with two hosts and one switch, then performs a ping test to check connectivity.

This script is intended as a preliminary step before tackling the more complex "INCS 775 - Data Center Security" assignment, specifically for tasks involving Mininet topology creation[cite: 16].

## Prerequisites

* **Mininet:** Must be installed and functional on your system (e.g., an Ubuntu VM). The assignment mentions Oracle VirtualBox or VMware Workstation Player for setting up the environment[cite: 2].
* **Python:** Required to execute the script[cite: 2]. Mininet itself is Python-based.
* **Sudo access:** Mininet typically requires superuser privileges to create and manage network interfaces and namespaces. The assignment notes a potential issue: "User is not in the sudoers file"[cite: 2, 21]. Ensure your user has the necessary `sudo` rights or Mininet is configured to run without them (less common for full functionality).

## How to Run

1.  **Save the Script:** Ensure the `mininet_env_test.py` script is saved on your machine where Mininet is installed.
2.  **Make it Executable (Optional):**
    ```bash
    chmod +x mininet_env_test.py
    ```
3.  **Execute the Script:**
    Run the script using `sudo`:
    ```bash
    sudo ./mininet_env_test.py
    ```
    Alternatively:
    ```bash
    sudo python mininet_env_test.py
    ```
4. **Execute the Script with mn --custom:**
    Run the script using `sudo`:
    ```bash
    sudo mn --custom ./mininet_env_test.py --topo=linear,3
    *** Creating network
    *** Adding controller
    *** Adding hosts:
    h1 h2 h3
    *** Adding switches:
    s1 s2 s3
    *** Adding links:
    (h1, s1) (h2, s2) (h3, s3) (s2, s1) (s3, s2)
    *** Configuring hosts
    h1 h2 h3
    *** Starting controller
    c0
    *** Starting 3 switches
    s1 s2 s3 ...
    *** Starting CLI:
    mininet> dump
    <Host h1: h1-eth0:10.0.0.1 pid=1940>
    <Host h2: h2-eth0:10.0.0.2 pid=1942>
    <Host h3: h3-eth0:10.0.0.3 pid=1944>
    <OVSSwitch s1: lo:127.0.0.1,s1-eth1:None,s1-eth2:None pid=1949>
    <OVSSwitch s2: lo:127.0.0.1,s2-eth1:None,s2-eth2:None,s2-eth3:None pid=1952>
    <OVSSwitch s3: lo:127.0.0.1,s3-eth1:None,s3-eth2:None pid=1955>
    <Controller c0: 127.0.0.1:6653 pid=1933>
    mininet> pingall
    *** Ping: testing ping reachability
    h1 -> h2 h3
    h2 -> h1 h3
    h3 -> h1 h2
    *** Results: 0% dropped (6/6 received)
    ```
## Expected Output

If your environment is set up correctly, the script will output messages indicating:
* The addition of hosts (`h1`, `h2`) and a switch (`s1`).
* The creation of links between them.
* The start of the network.
* The result of `net.pingAll()`. A successful test will show `0.0% dropped` packets.
* The stopping of the network.

Example of a successful ping portion of the output:
*** Testing network connectivity
h1 -> h2
h2 -> h1
*** Results: 0% dropped (2/2 received)
*** PingAll Result: 0.0 (0.0% dropped means success)


## Purpose of this Script

* **Environment Validation:** To confirm that you can run a basic Mininet script using Python.
* **Identify Core Issues:** Helps catch fundamental problems (e.g., Mininet not installed, Python path issues, `sudo` problems) before attempting the more complex Fat-Tree topology [cite: 16] and `ovs-ofctl` configurations [cite: 17] required by the assignment.
