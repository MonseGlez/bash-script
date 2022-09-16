import os
import socket
import sys
from unittest import result
import dns
import dns.resolver

# def modo_uso():
        # print('El modo de uso de este programa es:')

def get_dns_conf(zonename):
        result = dns.resolver.query(zonename,'A')
        for ipval in result:
                
                direccion_ip= (ipval.to_text())
                print(direccion_ip)
                if direccion_ip == 'localhost' or direccion_ip=='127.0.0.1':
                        print('el dominio '+ zonename + ' está configurada en :' + direccion_ip)
                else:
                        print('El dominio ' +zonename+ ' esta configurado en :'+ direccion_ip)
def get_status(servicio):

        status = os.system('systemctl status '+servicio+ ' > /dev/null')
        if (status == 0):
                print ("En ejecución")
        else:
                print ("No instalado o Detenido")
        return status


def get_port(port):

        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)                                      #2 Second Timeout
        result = sock.connect_ex(('127.0.0.1',port))
        if result == 0:
                print ('port OPEN')
        else: 
                print ('port CLOSED, connect_ex returned: '+str(result))

def get_install(servicio):
        if servicio == 'apache' or servicio == 'Apache':
                servicio= 'apache2'
        if servicio == 'dns' or servicio =='bind':
                servicio = 'bind9'
        if servicio == 'proxy' or servicio == 'squid':
                servicio = 'squid3'
        instalado = os.system('cat /lib/systemd/system/'+servicio+'.service')
        if (instalado == 0):
                print("El servicio "+servicio+' está instalado')
        else:
                print('El servicio '+servicio+' no está instalado')


#if __name__== "__main__":
        

get_port(int(sys.argv[1]))        
#get_dns_conf(sys. argv[1])
