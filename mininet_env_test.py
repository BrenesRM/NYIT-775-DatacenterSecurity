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

    # Create a Mininet object (without a default controller)
    # We'll use OVSKernelSwitch which is standard.
    net = Mininet(controller=None, switch=OVSKernelSwitch, link=TCLink)

    info('*** Adding hosts\n')
    h1 = net.addHost('h1', ip='10.0.0.1/24')
    h2 = net.addHost('h2', ip='10.0.0.2/24')

    info('*** Adding switch\n')
    s1 = net.addSwitch('s1')

    info('*** Creating links\n')
    # Add links between hosts and switch
    # For testing, we can specify basic link parameters if needed,
    # but defaults are fine for a basic environment check.
    net.addLink(h1, s1)
    net.addLink(h2, s1)

    info('*** Starting network\n')
    net.start()

    info('*** Testing network connectivity\n')
    # Perform a ping between the hosts to check connectivity
    # net.pingAll() will test reachability between all host pairs
    # For just two hosts, h1.cmd('ping -c 3 ' + h2.IP()) would also work
    result = net.pingAll()
    info(f'*** PingAll Result: {result} (0.0% dropped means success)\n')

    # If you want to interact with Mininet directly
    # CLI(net)

    info('*** Stopping network\n')
    net.stop()

if __name__ == '__main__':
    # Set the logging level to 'info' to see output from Mininet
    setLogLevel('info')
    basicTestTopology()
