# INCS 775 – Data Center Security (Summer 2025)

## 🧪 Assignment 1 – Fat-Tree Topology with Mininet

### 👨‍🏫 Instructor: Dr. Zakaria Alomari  
### 👤 Students: Marlon Brenes, Chengnan Jin, Wanpeng Cheng  
### 📅 Due Date: Wednesday, 11 June 2025 – 11:59 PM  

---

## 📘 Objective

- Build a **Fat-Tree topology with 6 pods** in Mininet using a custom Python script.
- Configure **bidirectional communication paths** between specific host pairs using `ovs-ofctl` flow rules (NO controller used).
- Run `iperf` and `ping` tests for performance evaluation.
- Export all required files as specified in the assignment instructions.

---

## 📁 Files Included

```plaintext
<lastname_firstname>/
│
├── Custom_FatTree_6Pods.py       # Python script to build Fat-Tree topology (k=6)
├── Group_info.txt                # Group member(s) name, ID, and email
│
├── Rules\Create_flow_rules.sh    # Flow rules for E1 switch
│
├── E1_dump                       # Output of `ovs-ofctl dump-flows E1`
│
├── iperf.out                     # Output from bandwidth tests
└── latency.out                   # Output from ping (RTT) tests
