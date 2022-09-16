#!/usr/bin/env python3

import socket
import sys
import threading

def revisarPuerto(host, puerto):
    cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        cliente.connect((host, puerto))
        return True
    except:
        return False
    finally:
        cliente.close()

def imprimirResultado(host, puerto, mutex):
    if revisarPuerto(host, puerto):
        mutex.acquire()
        print('Puerto %s abierto' % i)
        mutex.release()

mutex = threading.Lock()
for i in range(65536):
    threading.Thread(target=imprimirResultado, args=(sys.argv[1], i, mutex)).start()
