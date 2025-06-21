#!/usr/bin/env python3
"""
Custom Fat-Tree Topology for Mininet
INCS 775 - Data Center Security Assignment 2

This script creates a 4-pod Fat-Tree topology with:
- 16 Edge switches (E1-E16)
- 12 Aggregation switches (A1-A12)
- 8 Core switches (C1-C8)
- 48 Hosts (h1-h48)
"""

from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSSwitch
from mininet.link import Link, TCLink
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.topo import Topo
import time

class FatTreeTopo(Topo):
    """Fat-Tree topology implementation"""
    
    def __init__(self, k=4):
        """
        Initialize Fat-Tree topology
        k: number of pods (default: 4)
        """
        super(FatTreeTopo, self).__init__()
        self.k = k
        
        # Calculate topology parameters
        self.num_pods = k
        self.num_core_switches = (k // 2) ** 2
        self.num_agg_switches_per_pod = k // 2
        self.num_edge_switches_per_pod = k // 2
        self.num_hosts_per_edge = k // 2
        
        # Track switch and host counts
        self.core_switches = []
        self.agg_switches = []
        self.edge_switches = []
        self.hosts = []
        
        self.build_topology()
    
    def build_topology(self):
        """Build the complete Fat-Tree topology"""
        info("*** Building Fat-Tree topology\n")
        
        # Create core switches (C1-C8)
        self.create_core_switches()
        
        # Create pods with aggregation and edge switches
        self.create_pods()
        
        # Create hosts and connect to edge switches
        self.create_hosts()
        
        # Create inter-switch links
        self.create_core_to_agg_links()
        self.create_agg_to_edge_links()
        
        info("*** Fat-Tree topology created successfully\n")
    
    def create_core_switches(self):
        """Create core switches C1-C8"""
        info("*** Creating core switches\n")
        
        for i in range(1, self.num_core_switches + 1):
            switch_name = f'C{i}'
            dpid = f'00:00:00:00:00:0{i:02d}'  # Core switches: 00:00:00:00:00:01-08
            
            switch = self.addSwitch(
                switch_name,
                dpid=dpid,
                protocols='OpenFlow13'
            )
            self.core_switches.append(switch)
            info(f"Created core switch {switch_name} with DPID {dpid}\n")
    
    def create_pods(self):
        """Create pods with aggregation and edge switches"""
        info("*** Creating pods with aggregation and edge switches\n")
        
        for pod in range(self.num_pods):
            pod_agg_switches = []
            pod_edge_switches = []
            
            # Create aggregation switches for this pod (A1-A12)
            for i in range(self.num_agg_switches_per_pod):
                agg_index = pod * self.num_agg_switches_per_pod + i + 1
                switch_name = f'A{agg_index}'
                dpid = f'00:00:00:00:01:{agg_index:02d}'  # Agg switches: 00:00:00:00:01:01-12
                
                switch = self.addSwitch(
                    switch_name,
                    dpid=dpid,
                    protocols='OpenFlow13'
                )
                pod_agg_switches.append(switch)
                self.agg_switches.append(switch)
                info(f"Created aggregation switch {switch_name} with DPID {dpid}\n")
            
            # Create edge switches for this pod (E1-E16)
            for i in range(self.num_edge_switches_per_pod * 2):  # 4 edge switches per pod
                edge_index = pod * (self.num_edge_switches_per_pod * 2) + i + 1
                switch_name = f'E{edge_index}'
                dpid = f'00:00:00:00:02:{edge_index:02d}'  # Edge switches: 00:00:00:00:02:01-16
                
                switch = self.addSwitch(
                    switch_name,
                    dpid=dpid,
                    protocols='OpenFlow13'
                )
                pod_edge_switches.append(switch)
                self.edge_switches.append(switch)
                info(f"Created edge switch {switch_name} with DPID {dpid}\n")
    
    def create_hosts(self):
        """Create hosts and connect them to edge switches"""
        info("*** Creating hosts and connecting to edge switches\n")
        
        host_count = 1
        
        for edge_idx, edge_switch in enumerate(self.edge_switches):
            # Connect 3 hosts to each edge switch (48 hosts total)
            hosts_per_edge = 3
            
            for h in range(hosts_per_edge):
                if host_count <= 48:  # Limit to 48 hosts total
                    host_name = f'h{host_count}'
                    ip_addr = f'10.0.{edge_idx + 1}.{h + 1}/24'
                    mac_addr = f'00:00:00:00:{edge_idx + 1:02d}:{h + 1:02d}'
                    
                    host = self.addHost(
                        host_name,
                        ip=ip_addr,
                        mac=mac_addr
                    )
                    
                    # Connect host to edge switch
                    self.addLink(
                        host,
                        edge_switch,
                        bw=100,  # 100 Mbps
                        delay='1ms'
                    )
                    
                    self.hosts.append(host)
                    info(f"Created host {host_name} ({ip_addr}) connected to {edge_switch}\n")
                    host_count += 1
    
    def create_core_to_agg_links(self):
        """Create links between core and aggregation switches"""
        info("*** Creating core-to-aggregation links\n")
        
        # Each core switch connects to one aggregation switch in each pod
        for core_idx, core_switch in enumerate(self.core_switches):
            for pod in range(self.num_pods):
                # Connect to one aggregation switch per pod
                agg_idx = pod * self.num_agg_switches_per_pod + (core_idx % self.num_agg_switches_per_pod)
                agg_switch = self.agg_switches[agg_idx]
                
                self.addLink(
                    core_switch,
                    agg_switch,
                    bw=1000,  # 1 Gbps
                    delay='1ms'
                )
                info(f"Connected {core_switch} to {agg_switch}\n")
    
    def create_agg_to_edge_links(self):
        """Create links between aggregation and edge switches"""
        info("*** Creating aggregation-to-edge links\n")
        
        # Each aggregation switch connects to all edge switches in its pod
        for pod in range(self.num_pods):
            # Get aggregation switches for this pod
            pod_agg_start = pod * self.num_agg_switches_per_pod
            pod_agg_end = pod_agg_start + self.num_agg_switches_per_pod
            
            # Get edge switches for this pod
            pod_edge_start = pod * (self.num_edge_switches_per_pod * 2)
            pod_edge_end = pod_edge_start + (self.num_edge_switches_per_pod * 2)
            
            for agg_idx in range(pod_agg_start, pod_agg_end):
                agg_switch = self.agg_switches[agg_idx]
                
                for edge_idx in range(pod_edge_start, pod_edge_end):
                    edge_switch = self.edge_switches[edge_idx]
                    
                    self.addLink(
                        agg_switch,
                        edge_switch,
                        bw=1000,  # 1 Gbps
                        delay='1ms'
                    )
                    info(f"Connected {agg_switch} to {edge_switch}\n")

def create_controllers():
    """Create multiple controllers for FlowVisor slices"""
    controllers = []
    
    # Controller ports for each slice
    controller_ports = [4000, 5000, 6000, 7000]
    
    for i, port in enumerate(controller_ports):
        controller_name = f'c{i}'
        controller = RemoteController(
            controller_name,
            ip='127.0.0.1',
            port=port
        )
        controllers.append(controller)
        info(f"Created controller {controller_name} on port {port}\n")
    
    return controllers

def run_topology():
    """Run the Fat-Tree topology"""
    info("*** Starting Fat-Tree topology\n")
    
    # Set log level
    setLogLevel('info')
    
    # Create topology
    topo = FatTreeTopo(k=4)
    
    # Create network with multiple controllers
    controllers = create_controllers()
    
    net = Mininet(
        topo=topo,
        controller=None,  # We'll add controllers manually
        switch=OVSSwitch,
        link=TCLink,
        autoSetMacs=True,
        autoStaticArp=True
    )
    
    # Add controllers to network
    for controller in controllers:
        net.addController(controller)
    
    # Start network
    net.start()
    
    # Wait for network to stabilize
    time.sleep(5)
    
    # Print topology information
    print_topology_info(net)
    
    # Test basic connectivity
    info("*** Testing basic connectivity\n")
    net.pingAll()
    
    # Start CLI
    info("*** Starting CLI\n")
    CLI(net)
    
    # Stop network
    net.stop()

def print_topology_info(net):
    """Print detailed topology information"""
    info("*** Topology Information ***\n")
    
    # Print switches
    info("Core Switches:\n")
    for i in range(1, 9):
        switch_name = f'C{i}'
        if switch_name in net:
            info(f"  {switch_name}: DPID {net[switch_name].dpid}\n")
    
    info("Aggregation Switches:\n")
    for i in range(1, 13):
        switch_name = f'A{i}'
        if switch_name in net:
            info(f"  {switch_name}: DPID {net[switch_name].dpid}\n")
    
    info("Edge Switches:\n")
    for i in range(1, 17):
        switch_name = f'E{i}'
        if switch_name in net:
            info(f"  {switch_name}: DPID {net[switch_name].dpid}\n")
    
    # Print hosts
    info("Hosts:\n")
    for i in range(1, 49):
        host_name = f'h{i}'
        if host_name in net:
            host = net[host_name]
            info(f"  {host_name}: IP {host.IP()}, MAC {host.MAC()}\n")
    
    # Print slice-specific host groupings
    info("*** Slice Host Groupings ***\n")
    info("Red Slice Hosts: h8, h9, h11, h12\n")
    info("Green Slice Hosts: h28, h29, h30, h31, h32, h33, h34, h35, h36\n")
    info("Blue Slice Hosts: h31, h32, h33, h34, h35, h36\n")
    info("Pink Slice Hosts: h34, h35, h36, h45\n")

def test_slice_connectivity(net):
    """Test connectivity within defined slices"""
    info("*** Testing slice connectivity\n")
    
    # Define slice host groups
    slices = {
        'Red': ['h8', 'h9', 'h11', 'h12'],
        'Green': ['h28', 'h29', 'h30', 'h31', 'h32', 'h33', 'h34', 'h35', 'h36'],
        'Blue': ['h31', 'h32', 'h33', 'h34', 'h35', 'h36'],
        'Pink': ['h34', 'h35', 'h36', 'h45']
    }
    
    for slice_name, hosts in slices.items():
        info(f"Testing {slice_name} slice connectivity:\n")
        
        # Test connectivity between hosts in the same slice
        for i, host1 in enumerate(hosts):
            for host2 in hosts[i+1:]:
                if host1 in net and host2 in net:
                    result = net.ping([net[host1], net[host2]], timeout=1)
                    status = "SUCCESS" if result == 0 else "FAILED"
                    info(f"  {host1} -> {host2}: {status}\n")

if __name__ == '__main__':
    run_topology()