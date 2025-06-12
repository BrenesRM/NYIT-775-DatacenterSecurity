# INCS 775 – Data Center Security (Summer 2025)

## 🧪 Assignment 1 – Fat-Tree Topology with Mininet

### 👨‍🏫 Instructor: Dr. Zakaria Alomari  
### 👤 Students: Marlon Brenes, Chengnan Jin, Wanpeng Cheng  
### 📅 Due Date: Wednesday, 11 June 2025 – 11:59 PM  
### Github Repo: [Assigment 1](https://github.com/BrenesRM/NYIT-775-DatacenterSecurity/tree/main/Assignment_1)

---

# Assignment_1 – Fat‑Tree Mininet Topology & SDN Flow Rules 📘

This folder contains a **Mininet-based Fat‑Tree (k=6)** topology script, SDN flow-rule setup, and assignment documentation.

### 📂 Contents

- `Custom_FatTree_6Pods.py`  
  Builds a Fat‑Tree with 6 pods (C9 core, 18 agg, 18 edge switches, and 54 hosts).

- `Rules/Create_flow_rules_all.sh`  
  Bash script to install SDN flow rules for 6 host-to-host paths:
  - **Green**: h1 ↔ h4  
  - **Blue**: h3 ↔ h4  
  - **Red**: h10 ↔ h22  
  - **Purple**: h10 ↔ h13  
  - **Orange**: h37 ↔ h45  
  - **Pink**: h38 ↔ h43

- `Assignment_1_Summer_2025.pdf`, `Assigment_1.html`  
  Assignment specification and documentation.

- `Group_info.txt`  
  Your team’s info.

- `Notes.txt`  
  Quick run reminders.

---

## 🛠️ Prerequisites

- Linux system
- **Mininet** installed with:
  - `OVSSwitch`
  - `TCLink`
- **Open vSwitch** management tools (`ovs-ofctl`, `ovs-vsctl`)

---

## 🚀 How to Use

1. **Clean Mininet** (optional):
   ```bash
   sudo mn -c
   ```
2. **Start Topology**:
   ```bash
   sudo mn --custom ./Custom_FatTree_6Pods.py --topo=fattree --link=tc --switch=ovsk --controller=none
   ```
   This drops you into the Mininet CLI:
   ```
   mininet>
   ```
3. **In parallel terminal**, grant execute permission and install flow rules:
   ```bash
   In the folder Rules/
    # If needed, run dos2unix and chmod +x for each .sh rule for a proper execution.
    sudo apt update
    sudo apt install dos2unix
    dos2unix Create_flow_rules_all.sh

    # To run all the rules:
    chmod +x Create_flow_rules_all.sh
    ./Create_flow_rules_all.sh
   ```
   This script:
   - Clears existing flows
   - Adds ARP & IP rules for all test paths with priorities
   - Dumps `ovs-ofctl` outputs to verify

4. **Verify connectivity** inside CLI:
   ```bash
   mininet> pingall
   mininet> iperf h1 h4    # Example test
   ```

5. **Run your own performance tests** (ping, iperf) as needed.

---

## ✅ Flow Rule Path Summary

| Path     | Hosts         | Switch Sequence                              | Priority |
|----------|----------------|----------------------------------------------|----------|
| Green    | h1 ↔ h4        | E1 → A1 → E2                                  | 200      |
| Blue     | h3 ↔ h4        | E1 → A1 → E2                                  | 175      |
| Red      | h10 ↔ h22      | E4 → A5 → C4 → A8 → E8                         | 65       |
| Purple   | h10 ↔ h13      | E4 → A5 → E5                                   | 65       |
| Orange   | h37 ↔ h45      | E13 → A15 → E15                                | 60       |
| Pink     | h38 ↔ h43      | E13 → A15 → E15                                | 55       |

Reverse flow rules are installed for bidirectional traffic.

---

## 💬 Notes

- Links between hosts & switches all use **12 Mbps** limit and **2 ms delay**.
- Flow rules include separate **ARP** and **IP** matches.
- Catch-all `priority=1` rules drop any non-specified traffic.
- Output of `ovs-ofctl dump-flows` commands are printed during script run for debugging.

---

## 🎯 Running Assignment Tests

To fully execute and log your assignment results:

1. **Apply flow rules** as shown above.
2. Run **iperf** and **ping** tests for all six host pairs.
3. **Capture output** into required formats (`iperf.out`, `latency.out`).
4. Include `*_dump` files as evidence of switches’ flow tables.

---

## 📄 References

- Assignment PDF and HTML in this directory.
- `Custom_FatTree_6Pods.py` contains topology details.
- `Create_flow_rules_all.sh` orchestrates everything.
- `Assigment_1.html` Architecture of the Fat Tree.

---
