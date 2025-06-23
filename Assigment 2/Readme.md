
# FlowVisor + Mininet: Data Center Security Lab (Red Slice Configuration)

This guide outlines the proper step-by-step order to configure and run a Fat-Tree topology with FlowVisor slices and POX controllers.

---

## ✅ Prerequisites

- FlowVisor is installed and configured
- POX controller is available in `./pox`
- `Custom_FatTree_6Pods.py` exists in working directory
- `flowvisor_config.sh` script is executable and configured for Red slice
- Slice password file is named `pwd`

---

## 🛠 Step-by-Step Execution

### 1. Load FlowVisor Configuration

```bash
fvconfig load /etc/flowvisor/config.json
```

### 2. Start and Check FlowVisor Status

```bash
sudo /etc/init.d/flowvisor start
sudo /etc/init.d/flowvisor status
tail -f /var/log/flowvisor/test.log  # Optional: Watch logs
```

### 3. Enable Topology Control

```bash
sudo fvctl -f pwd set-config --enable-topo-ctrl
sudo fvctl -f pwd get-config
```

### 4. Prepare Test Script (Optional)

```bash
sudo apt-get install dos2unix
dos2unix flowvisor_test.sh
./flowvisor_test.sh
```

### 5. Configure the Red Slice

```bash
sudo ./flowvisor_config.sh --red
```

### 6. Verify Slice & FlowSpace

```bash
fvctl -f pwd list-slices
fvctl -f pwd list-flowspace
fvctl -f pwd list-datapaths
fvctl -f pwd list-slice-info Red
```

### 7. Start POX Controller

```bash
sudo ./pox.py forwarding.l2_learning openflow.of_01 --address=127.0.0.1 --port=4000
```

### 8. Cleanup and Launch Mininet

```bash
sudo mn -c
sudo mn --custom ./Custom_FatTree_6Pods.py --topo=fattree --link=tc --switch ovsk,protocol=OpenFlow10 --controller=remote,ip=127.0.0.1,port=6633
```

---

## 📌 Notes

- Make sure POX is listening on the correct port before launching Mininet.
- Each slice should be configured individually via `flowvisor_config.sh`.
- You can repeat similar steps for Blue, Green, and Pink slices.

---

## 🔐 Password File Format

Create a `pwd` file with:

```
fvadmin:<your-password>
```

This allows `fvctl` to authenticate using the `--passwd-file=pwd` option.

---

## 🧪 Test Connectivity

Once in the Mininet CLI:

```bash
pingall
```

Or test specific slice hosts:

```bash
h8 ping -c 3 h9
h11 ping -c 3 h12
```

---

## ✅ Done!
You now have a working SDN slice-based data center topology using FlowVisor + POX + Mininet!
