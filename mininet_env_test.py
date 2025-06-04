#!/usr/bin/python
from mininet.net import Mininet
from mininet.node import Controller, OVSKernelSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink

def basicTestTopology():
    """
    Creates and runs a minimal Mininet topology for environment testing.
    FIXED VERSION: Now includes a controller for proper packet forwarding.
    """
    # FIXED: Add controller=Controller instead of controller=None
    net = Mininet(controller=Controller, switch=OVSKernelSwitch, link=TCLink)
    
    info('*** Adding controller\n')
    # FIXED: Explicitly add the controller
    c0 = net.addController('c0')
    
    info('*** Adding hosts\n')
    h1 = net.addHost('h1', ip='10.0.0.1/24')
    h2 = net.addHost('h2', ip='10.0.0.2/24')
    
    info('*** Adding switch\n')
    s1 = net.addSwitch('s1')
    
    info('*** Creating links\n')
    net.addLink(h1, s1)
    net.addLink(h2, s1)
    
    info('*** Starting network\n')
    net.start()
    
    info('*** Testing network connectivity\n')
    result = net.pingAll()
    info(f'*** PingAll Result: {result}% dropped (0.0% means success)\n')
    
    # Show success/failure clearly
    if result == 0.0:
        print("✅ SUCCESS: Network connectivity working!")
    else:
        print(f"❌ FAILURE: {result}% packet loss")
    
    # Uncomment next line if you want interactive CLI
    # CLI(net)
    
    info('*** Stopping network\n')
    net.stop()

if __name__ == '__main__':  # FIXED: Double underscores
    setLogLevel('info')
    basicTestTopology()
