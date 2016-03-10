#!/usr/bin/python
import socket
import sys

# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect the socket to the port where the server is listening
port = 63260
server_address = ('localhost', port)
print >>sys.stderr, 'connecting to %s port %s' % server_address
sock.connect(server_address)
sock.sendall('set a 10')
sock.recv(1024)
sock.close()

