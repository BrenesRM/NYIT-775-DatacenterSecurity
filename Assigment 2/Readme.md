# Mininet Fat-Tree Topology with FlowVisor Slicing

This project demonstrates how to build and manage a 6-pod Fat-Tree topology in Mininet, integrated with FlowVisor for SDN slicing.

## 📦 Prerequisites

- Ubuntu (20.04+ recommended)
- Mininet installed
- FlowVisor installed
- POX Controller
- `Custom_FatTree_6Pods.py` topology script
- Slice and FlowSpace setup scripts:
  - `Create_Slices.sh`
  - `flowspace_red.sh`
  - `flowspace_green.sh`
  - `flowspace_blue.sh`
  - `flowspace_pink.sh`

## 🚀 1. Load FlowVisor Configuration

```bash
fvconfig load /etc/flowvisor/config.json
```

## 🟢 2. Start and Check FlowVisor Status

```bash
sudo /etc/init.d/flowvisor start
sudo /etc/init.d/flowvisor status
tail -f /var/log/flowvisor/test.log   # (Optional) Watch logs
```

## 🌐 3. Enable Topology Control

```bash
sudo fvctl -f pwd set-config --enable-topo-ctrl
sudo fvctl -f pwd get-config
```

## 🏗️ 4. Deploy 6-Pod Fat-Tree Topology Using Mininet

```bash
sudo mn --custom ./Custom_FatTree_6Pods.py --topo=fattree --link=tc --arp --mac --controller=remote,ip=127.0.0.1,port=6633 --switch ovsk,protocols=OpenFlow10
Wait into the topology is created
```

## 🧩 5. Deploy Slices and FlowSpaces

```bash
sudo apt install dos2unix
dos2unix Create_Slices.sh && chmod +x Create_Slices.sh && ./Create_Slices.sh

dos2unix flowspace_red.sh flowspace_green.sh flowspace_blue.sh flowspace_pink.sh    
chmod +x flowspace_red.sh flowspace_green.sh flowspace_blue.sh flowspace_pink.sh
./flowspace_red.sh
./flowspace_green.sh
./flowspace_blue.sh.
./flowspace_pink.sh

```

## 🔍 6. Verify Slices and FlowSpaces

```bash
fvctl -f pwd list-slices
fvctl -f pwd list-flowspace
fvctl -f pwd list-datapaths
fvctl -f pwd list-slice-info Red
```

### 🔄 To Delete a Slice:

```bash
fvctl --passwd-file=pwd remove-slice Red
```

## 🧠 7. Start POX Controllers

```bash
sudo ./pox.py forwarding.l2_learning openflow.of_01 --address=127.0.0.1 --port=4000
sudo ./pox.py forwarding.l2_learning openflow.of_01 --address=127.0.0.1 --port=5000
sudo ./pox.py forwarding.l2_learning openflow.of_01 --address=127.0.0.1 --port=6000
sudo ./pox.py forwarding.l2_learning openflow.of_01 --address=127.0.0.1 --port=7000
```

## 🧪 8. Test

Run pings between hosts within the same slice to confirm slice isolation and forwarding.

## 📝 9. Logging of Deliverables

```bash
fvctl -f pwd list-slice-info Red &> Red
fvctl -f pwd list-slice-info Green &> Green
fvctl -f pwd list-slice-info Blue &> Blue
fvctl -f pwd list-slice-info Pink &> Pink

fvctl -f pwd list-flowspace | grep Red &> Red_FS
fvctl -f pwd list-flowspace | grep Green &> Green_FS
fvctl -f pwd list-flowspace | grep Blue &> Blue_FS
fvctl -f pwd list-flowspace | grep Pink &> Pink_FS

fvctl -f pwd list-flowspace &> flowspace
```

## 📌 Notes

- Ensure your POX controllers use the correct ports matching the slices.
- All FlowVisor commands require a valid `pwd` password file.

## 📁 Directory Structure Example

```bash
.
├── Custom_FatTree_6Pods.py
├── Create_Slices.sh
├── flowspace_red.sh
├── flowspace_green.sh
├── flowspace_blue.sh
├── flowspace_pink.sh
├── README.md
└── pwd
```

## 🛠 Troubleshooting

- **FlowVisor not starting**: Check `/var/log/flowvisor/test.log` for errors.
- **Missing flows**: Re-run the slice/flowspace scripts or verify controller connectivity.
- **Controller not forwarding packets**: Ensure POX is using `openflow.of_01` and the correct port.
