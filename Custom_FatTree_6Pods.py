#!/usr/bin/env python3

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import OVSSwitch
from mininet.link import TCLink
from mininet.log import setLogLevel
from mininet.cli import CLI
import time

class FatTreeTopo(Topo):
    """Fat Tree topology with k=6 pods"""
    
    def __init__(self, k=6):
        Topo.__init__(self)
        self.k = k
        self.pod_count = k
        self.core_switches = []
        self.aggregation_switches = []
        self.edge_switches = []
        self.hosts = []
        
        # Build the topology
        self.build_topology()
    
    def build_topology(self):
        """Build Fat Tree topology with k=6"""
        
        # Calculate number of switches and hosts
        num_core = (self.k // 2) ** 2  # 9 core switches
        num_agg_per_pod = self.k // 2  # 3 aggregation switches per pod
        num_edge_per_pod = self.k // 2  # 3 edge switches per pod
        num_hosts_per_edge = self.k // 2  # 3 hosts per edge switch
        
        print(f"Building Fat Tree with k={self.k}")
        print(f"Core switches: {num_core}")
        print(f"Aggregation switches per pod: {num_agg_per_pod}")
        print(f"Edge switches per pod: {num_edge_per_pod}")
        print(f"Hosts per edge switch: {num_hosts_per_edge}")
        
        # Create core switches
        for i in range(num_core):
            core_switch = self.addSwitch(f'C{i+1}')
            self.core_switches.append(core_switch)
        
        # Create pods
        host_id = 1
        for pod in range(self.pod_count):
            pod_agg_switches = []
            pod_edge_switches = []
            
            # Create aggregation switches for this pod
            for i in range(num_agg_per_pod):
                agg_switch = self.addSwitch(f'A{pod * num_agg_per_pod + i + 1}')
                pod_agg_switches.append(agg_switch)
                self.aggregation_switches.append(agg_switch)
            
            # Create edge switches for this pod
            for i in range(num_edge_per_pod):
                edge_switch = self.addSwitch(f'E{pod * num_edge_per_pod + i + 1}')
                pod_edge_switches.append(edge_switch)
                self.edge_switches.append(edge_switch)
                
                # Create hosts connected to this edge switch
                for j in range(num_hosts_per_edge):
                    host = self.addHost(f'h{host_id}')
                    self.hosts.append(host)
                    
                    # Connect host to edge switch
                    self.addLink(host, edge_switch, 
                               bw=12, delay='2ms', use_htb=True)
                    host_id += 1
            
            # Connect edge switches to aggregation switches (complete bipartite)
            for edge in pod_edge_switches:
                for agg in pod_agg_switches:
                    self.addLink(edge, agg, 
                               bw=12, delay='2ms', use_htb=True)
            
            # Connect aggregation switches to core switches
            for i, agg in enumerate(pod_agg_switches):
                # Each aggregation switch connects to k/2 core switches
                start_core = i * (self.k // 2)
                for j in range(self.k // 2):
                    core_idx = start_core + j
                    if core_idx < len(self.core_switches):
                        self.addLink(agg, self.core_switches[core_idx],
                                   bw=12, delay='2ms', use_htb=True)

def run_tests(net):
    """Run iperf and ping tests"""
    print("Running iperf tests...")
    
    # iperf tests
    test_pairs = [
        ('h1', 'h4'),
        ('h3', 'h4'), 
        ('h10', 'h22'),
        ('h10', 'h13'),
        ('h37', 'h45'),
        ('h38', 'h43')
    ]
    
    iperf_results = []
    for src, dst in test_pairs:
        print(f"Testing iperf between {src} and {dst}")
        result = net.iperf([net.get(src), net.get(dst)])
        iperf_results.append(f"{src} {dst}: {result}")
    
    # Save iperf results
    with open('iperf.out', 'w') as f:
        for result in iperf_results:
            f.write(result + '\n')
    
    print("Running ping tests...")
    ping_results = []
    for src, dst in test_pairs:
        print(f"Testing ping between {src} and {dst}")
        src_host = net.get(src)
        result = src_host.cmd(f'ping -c 20 {net.get(dst).IP()}')
        # Parse ping results to get average RTT
        lines = result.split('\n')
        for line in lines:
            if 'rtt min/avg/max/mdev' in line:
                avg_rtt = line.split('=')[1].split('/')[1]
                ping_results.append(f"{src} {dst}: {avg_rtt} ms")
                break
    
    # Save ping results
    with open('latency.out', 'w') as f:
        for result in ping_results:
            f.write(result + '\n')

# This makes the topology available for --custom parameter
topos = {'fattree': FatTreeTopo}

def main():
    """Main function to create and run the Fat Tree topology"""
    setLogLevel('info')
    
    # Create topology
    topo = FatTreeTopo(k=6)
    
    # Create network
    net = Mininet(topo=topo, 
                  switch=OVSSwitch,
                  link=TCLink,
                  controller=None)  # No controller as specified
    
    # Start network
    net.start()
    
    print("Fat Tree topology created successfully!")
    print("Network started. Use 'nodes' to see all nodes.")
    print("Use 'links' to see all links.")
    print("Remember to set up flow rules using ovs-ofctl before testing!")
    
    # Start CLI for manual configuration
    CLI(net)
    
    # Stop network
    net.stop()

if __name__ == '__main__':
    main()
