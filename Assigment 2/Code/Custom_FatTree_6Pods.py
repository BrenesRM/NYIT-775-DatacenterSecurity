#!/usr/bin/env python3

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import OVSSwitch
from mininet.link import TCLink
from mininet.log import setLogLevel
from mininet.cli import CLI


class FatTreeTopo(Topo):
    """Fat Tree topology with k=6 pods and unique DPID assignment"""

    def __init__(self, k=6):
        super(FatTreeTopo, self).__init__()
        self.k = k
        self.pod_count = k
        self.core_switches_list = []
        self.aggregation_switches_list = []
        self.edge_switches_list = []
        self.hosts_list = []

        self.build_topology()

    def build_topology(self):
        """Build Fat Tree topology with k=6 and unique DPIDs"""

        num_core = (self.k // 2) ** 2
        num_agg_per_pod = self.k // 2
        num_edge_per_pod = self.k // 2
        num_hosts_per_edge = self.k // 2

        print(f"Building Fat Tree with k={self.k}")
        print(f"Core switches: {num_core}")
        print(f"Aggregation switches per pod: {num_agg_per_pod}")
        print(f"Edge switches per pod: {num_edge_per_pod}")
        print(f"Hosts per edge switch: {num_hosts_per_edge}")

        # Core switches
        for i in range(num_core):
            dpid = f'{i + 1:016x}'  # e.g., 0x0000000000000001
            core_switch = self.addSwitch(f'C{i + 1}', dpid=dpid)
            self.core_switches_list.append(core_switch)

        host_id = 1

        for pod in range(self.pod_count):
            pod_agg_switches = []
            pod_edge_switches = []

            # Aggregation switches
            for i in range(num_agg_per_pod):
                agg_id = pod * num_agg_per_pod + i + 1
                dpid = f'{0x100 + agg_id:016x}'  # e.g., 0x0000000000000101
                agg_switch = self.addSwitch(f'A{agg_id}', dpid=dpid)
                pod_agg_switches.append(agg_switch)
                self.aggregation_switches_list.append(agg_switch)

            # Edge switches + hosts
            for i in range(num_edge_per_pod):
                edge_id = pod * num_edge_per_pod + i + 1
                dpid = f'{0x200 + edge_id:016x}'  # e.g., 0x0000000000000201
                edge_switch = self.addSwitch(f'E{edge_id}', dpid=dpid)
                pod_edge_switches.append(edge_switch)
                self.edge_switches_list.append(edge_switch)

                for j in range(num_hosts_per_edge):
                    host = self.addHost(f'h{host_id}')
                    self.hosts_list.append(host)
                    self.addLink(host, edge_switch, bw=12, delay='2ms', use_htb=True)
                    host_id += 1

            # Edge ↔ Aggregation links
            for edge in pod_edge_switches:
                for agg in pod_agg_switches:
                    self.addLink(edge, agg, bw=12, delay='2ms', use_htb=True)

            # Aggregation ↔ Core links
            for i in range(len(pod_agg_switches)):
                agg = pod_agg_switches[i]
                for j in range(self.k // 2):
                    core_index = i * (self.k // 2) + j
                    if core_index < len(self.core_switches_list):
                        core = self.core_switches_list[core_index]
                        self.addLink(agg, core, bw=12, delay='2ms', use_htb=True)


def main():
    """Create and run the Fat Tree topology"""
    setLogLevel('info')

    topo = FatTreeTopo(k=6)

    net = Mininet(topo=topo,
                  switch=OVSSwitch,
                  link=TCLink,
                  controller=None)

    net.start()

    print("\n✅ Fat Tree topology with unique DPIDs created successfully!")
    print("🔧 Use 'nodes' or 'net' to inspect the network.")
    print("⚠️  Set up flow rules using ovs-ofctl before running iperf/ping tests.")

    CLI(net)
    net.stop()


# Register topology so Mininet can find it using --topo=fattree
topos = {
    'fattree': (lambda: FatTreeTopo(k=6))
}

# Run directly
if __name__ == '__main__':
    main()
