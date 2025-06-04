#!/usr/bin/python

from mininet.net import Mininet
from mininet.node import Controller, OVSKernelSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink

def basicTestTopology():
    """
    Creates and runs a minimal Mininet topology for environment testing.
    """

    # Create a Mininet object with a default controller
    net = Mininet(controller=Controller, switch=OVSKernelSwitch, link=TCLink)

    info('*** Adding controller\n')
    net.addController('c0')  # Default controller

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
    result = net.pingAll()  # Test connectivity between all hosts
    info(f'*** PingAll Result: {result} (0.0% dropped means success)\n')

    info('*** Stopping network\n')
    net.stop()

if __name__ == '__main__':
    # Set the logging level to 'info' to see output from Mininet
    setLogLevel('info')
    basicTestTopology()
