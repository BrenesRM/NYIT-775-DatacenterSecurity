#!/usr/bin/python3

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import RemoteController, OVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel

class CustomFatTree(Topo):
    def build(self):
        # Core switches
        core = {}
        for i in range(1, 8):
            name = f'C{i}'
            core[name] = self.addSwitch(name)

        # Aggregation switches
        agg = {}
        for i in range(1, 16):
            name = f'A{i}'
            agg[name] = self.addSwitch(name)

        # Edge switches
        edge = {}
        for i in range(1, 16):
            name = f'E{i}'
            edge[name] = self.addSwitch(name)

        # Hosts
        host_counter = 1
        for i in range(1, 16):
            e = edge[f'E{i}']
            for j in range(3):  # 3 hosts per edge switch = 15 x 3 = 45
                hname = f'h{host_counter}'
                host = self.addHost(hname)
                self.addLink(e, host)
                host_counter += 1

        # Connect Edge to Aggregation (E1-E15 to A1-A15)
        for i in range(1, 16):
            e = edge[f'E{i}']
            a = agg[f'A{i}']
            self.addLink(e, a)

        # Connect Aggregation to Core (A1-A15 to C1-C7) - simplified rule
        for i in range(1, 16):
            a = agg[f'A{i}']
            core_index = (i % 7) + 1  # distributes connections
            c = core[f'C{core_index}']
            self.addLink(a, c)

def run():
    topo = CustomFatTree()
    net = Mininet(topo=topo, switch=OVSSwitch, controller=None, autoSetMacs=True)
    
    # Add all remote controllers (you'll configure them later)
    c1 = net.addController('c4000', controller=RemoteController, ip='127.0.0.1', port=4000)
    c2 = net.addController('c5000', controller=RemoteController, ip='127.0.0.1', port=5000)
    c3 = net.addController('c6000', controller=RemoteController, ip='127.0.0.1', port=6000)
    c4 = net.addController('c7000', controller=RemoteController, ip='127.0.0.1', port=7000)

    net.start()
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    run()
