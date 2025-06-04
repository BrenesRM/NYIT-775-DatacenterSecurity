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
├── E1_flow.txt                   # Flow rules for E1 switch
├── A1_flow.txt
├── E2_flow.txt
├── E4_flow.txt
├── A5_flow.txt
├── E5_flow.txt
├── C4_flow.txt
├── A8_flow.txt
├── E8_flow.txt
├── E13_flow.txt
├── A15_flow.txt
├── E15_flow.txt
│
├── E1_dump                       # Output of `ovs-ofctl dump-flows E1`
├── A1_dump
├── E2_dump
├── E4_dump
├── A5_dump
├── E5_dump
├── C4_dump
├── A8_dump
├── E8_dump
├── E13_dump
├── A15_dump
├── E15_dump
│
├── iperf.out                     # Output from bandwidth tests
└── latency.out                   # Output from ping (RTT) tests
