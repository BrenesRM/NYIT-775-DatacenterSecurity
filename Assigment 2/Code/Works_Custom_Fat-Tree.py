from mininet.topo import Topo

class MyFatTree(Topo):
    def build(self):
        print("*** Building Fat-Tree topology")

        core_switches = []
        agg_switches = []
        edge_switches = []
        host_count = 1

        # Core layer (4 core switches for k=4)
        for i in range(1, 5):
            sw = self.addSwitch(f'C{i}', dpid=f'000000000000000{i}')
            core_switches.append(sw)

        # Pods (4 pods for k=4)
        for pod in range(4):
            agg1 = self.addSwitch(f'A{pod*2+1}', dpid=f'0000000000010{pod*2+1}')
            agg2 = self.addSwitch(f'A{pod*2+2}', dpid=f'0000000000010{pod*2+2}')
            agg_switches.extend([agg1, agg2])

            edge_group = []
            for i in range(4):
                edge_index = pod * 4 + i + 1
                edge = self.addSwitch(f'E{edge_index}', dpid=f'0000000000020{edge_index:02d}')
                edge_switches.append(edge)
                edge_group.append(edge)

                # Add 3 hosts per edge switch
                for j in range(3):
                    host = self.addHost(f'h{host_count}', ip=f'10.0.{edge_index}.{j+1}/24')
                    self.addLink(edge, host)
                    host_count += 1

            # Connect aggregation to edge
            for agg in [agg1, agg2]:
                for edge in edge_group:
                    self.addLink(agg, edge)

        # Connect core to aggregation
        for i, core in enumerate(core_switches):
            for j in range(i, len(agg_switches), 4):  # Distribute evenly
                self.addLink(core, agg_switches[j])

# Required by Mininet when using --custom
# Provides a dictionary that maps topology names to classes
# Usage: sudo mn --custom Custom_Fat-Tree.py --topo mytopo

topos = {"mytopo": MyFatTree}
