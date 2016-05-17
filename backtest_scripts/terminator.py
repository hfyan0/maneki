#!/usr/bin/python
import socket
import sys

PORT=60934

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = ('localhost', PORT)
sock.bind(server_address)
sock.settimeout(120)
sock.listen(1)

# blocking here
connection, client_address = sock.accept()

try:
    data = connection.recv(1)

finally:
    connection.close()
    sock.close()
