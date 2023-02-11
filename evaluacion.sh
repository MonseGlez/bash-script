#!/bin/bash
rojo=`tput setaf 1`
amarillo=`tput setaf 3`
verde=`tput setaf 2`
blanco=`tput setaf 7`
azul=`tput setaf 4`
gris=`tput setaf 251`
instalacion(){
    if [ "$1" == "apache" ]; then
    servicio="apache2"

    elif [ "$1" == "dns" ];then
    servicio="named"
    elif [ "$1" == "proxy" ];then
    servicio="squid"
    
    fi

    cat /lib/systemd/system/"$servicio".service 1>> $file_respuesta 2>> $file_errores
    if [ $? == 0 ]; then
        echo "${verde} El servicio "$servicio" está instalado correctamente"
        zcat /var/log/apt/history.log.*.gz | cat - /var/log/dpkg.log | grep -E 'install' |grep $1  
        if [ $? == 0 ]; then
        echo "${azul}Instalado desde APT"
        echo "${azul}Instalado desde APT" >> file_evaluacion
        echo "${verde}Servicio="$servicio"">> $file_evaluacion
        else
         echo "${azul} Instalado desde compilacion"
        fi
	echo "${verde}Instalado=Sí" >> $file_evaluacion
    else
        echo "${rojo} El servicio "$servicio" no está instalado"
        echo "${rojo}Servicio="$servicio"" >> $file_evaluacion
	echo "${rojo}Instalado=No" >> $file_evaluacion
    fi
}
evaluacion(){
instalacion $servicio_web 
puerto $servicio_web $puerto_web
instalacion $servicio_dns
puerto $servicio_dns $puerto_dns
}
puerto(){
   if [ "$1" == "apache" ]; then
    sudo lsof -i:$2 -n -P | awk {'print $1'} | grep apache2

   elif [ "$1" == "dns" ];then
    sudo lsof -i:$2 -n -P | awk {'print $1'} | grep named
   elif [ "$1" == "proxy" ]; then
    sudo lsof -i:3128 -n -P | awk {'print $1'} | grep squid
    fi
   
   if [ $? == 0 ]; then 
       echo "${verde} El servicio "$1" corriendo en el puerto "$2"" 
       echo "${verde}Puerto=Sí" >> $file_evaluacion
        if [ $1 == "named" ]; then 
       echo "direccion de la zona dns configurada:"
       nslookup $3 | grep Address | awk '{print $2}'| sed -n 2p
       echo "Se configuro el dominio $3 en la ip: " $(nslookup $3| grep Address | awk '{print $2}'| sed -n 2p) >> $file_evaluacion
       fi
   else
       echo "${rojo} El servicio "$servicio" no está ejecutandose en el puerto "$2""
       echo "${rojo}Puerto=No " >> $file_evaluacion

fi
}
archivos(){
mkdir ~/.evaluacion 2>> /dev/null
file_evaluacion=~/.evaluacion/evaluacion-$1-$(date +"%d-%m-%Y").txt
file_errores=~/.evaluacion/salidaerror-$1-$(date +"%d-%m-%Y").txt
file_respuesta=~/.evaluacion/salida-$1-$(date +"%d-%m-%Y").txt
if [ -f $file_evaluacion ]
then
   echo ""
   
else
   touch $file_evaluacion
   echo "Matricula="$1>> $file_evaluacion
fi
} 
menu() {
file_mount_nfs=~/.mnt_nfs/
mkdir $file_mount_nfs 2>> /dev/null
ip_alumno=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')

echo "${verde}ingresa tu matricula"
read matricula

archivos $matricula
echo "${gris} Ingresaste la matricula:'$matricula'"
echo "${gris} ¿Es correcta? 1. Si 2. No"
read matricula_verifica
if [ "$matricula_verifica" == "2" ]; then
 echo "${gris}Ingresa la matricula nuevamente"
 read matricula
fi
if [ "$matricula_verifica" == "" ]; then
         echo "${rojo}No se aceptan respuestas vacias"
         echo "${rojo}Ejecuta nuevamente el script."
         exit
fi
echo "${azul}¿Qué actividad finalizaste?"
echo "${azul}1) Servidor Web "
echo "${azul}2) Servidor DNS "
echo "${azul}3) Servidor Proxy "
echo "${azul}4 ) Salir "
read opcion  

case $opcion in
    1) echo  "Evaluación servicio Web"
       echo  "¿Está configurado en el puerto por defecto? (80) 1. Si 2. No "
       read respuesta
       if [ "$respuesta" == "" ]; then
         echo "${rojo}No se aceptan respuestas vacias"
         echo "${rojo}Ejecuta nuevamente el script."
         exit
      fi
      if [ "$respuesta" == "1" ]; then
        puerto="80"
        servicio="apache"
        instalacion $servicio
        puerto $servicio $puerto
      else
        echo "¿En que puerto te fue solicitado?"
        read puerto_custom 
        servicio="apache"
        puerto=$puerto_custom
        instalacion $servicio
        puerto $servicio $puerto 
     fi  
     echo "Los virtual host configurados son : "
     a2query -s
     if [ $? == 0 ]; then 
	    echo "${amarillo}los virtual host configurados son: " $(a2query -s) >> $file_evaluacion
    	echo "${gris}Fecha y hora de evaluación " $(date) >> $file_evaluacion
        envio_maestro
     else
	    echo "${rojo}No esta configurado ningún virtualhost"
	    echo "${rojo}No esta configurado ningún virtualhost" >> $file_evaluacion
 	   fi
    ;; 
    2)
       
       echo  "Evaluación servicio DNS"
       echo  "¿Está configurado en el puerto por defecto? (53) 1. Si 2. No"
       read respuesta
       echo "¿Cuál es el nombre de dominio que configuraste?"
       read name_zone
      if [ "$respuesta" == "" ]; then
         echo "${rojo}No se aceptan respuestas vacias"
         echo "${rojo}Ejecuta nuevamente el script."
         exit
      fi
      if [ "$respuesta" == "1" ]; then
        puerto="53"
        servicio="dns"
        instalacion $servicio
        puerto $servicio $puerto $name_zone
        
      else
        echo "¿En que puerto te fue solicitado?"
        read puerto_custom 
        puerto = $puerto_custom
        servicio = "dns"
        instalacion $servicio
        puerto $servicio $puerto $name_zone
      fi  
   
    cd /etc/bind
    archivo_dns=$(ls -l | grep $name_zone | awk '{print $9}')

    ls -l | grep $name_zone | awk '{print $9}'
    archivo_db=/etc/bind/$archivo_dns
    if [ -f $archivo_db  ]; then

        echo "${amarillo} Se ejecutará la revisión de sintaxis del archivo: '$archivo_dns'"
        sudo named-checkzone $name_zone $archivo_dns 
        echo "${amarillo} Se ejecutará la revisión de sintaxis del archivo: '$archivo_dns'" >> $file_evaluacion
        sudo named-checkzone $name_zone $archivo_dns >> $file_evaluacion        
    else
        echo "${rojo}No se encuentra el archivo de db donde esta definida la zona"
        echo "${rojo}No se encuentra el archivo de db donde esta definida la zona" >> $file_evaluacion

    fi
    echo "${gris}Fecha y hora de evaluación " $(date) >> $file_evaluacion
    envio_maestro
    
    ;; 
    3) echo "Evaluación servidor Proxy"
    puerto="3128"
    servicio="squid"
    url_proxy="facebook.com"
    instalacion $servicio
    puerto $servicio $puerto
    echo "Se evaluara que el proxy bloquee la red social facebook."
    status_code=`curl -k --silent --output /dev/null -L -w "\n%{http_code}" $url_proxy |tail -n 1`
    if [ "$status_code" == "200" ]; then
      echo "${rojo}El proxy No está bloqueando el sitio. Conexión permitida"
      echo "${rojo}El proxy No está bloqueando el sitio. Conexión permitida" >> $file_evaluacion
    fi
    if [ "$status_code" == "403" ]; then
      echo "${verde}El proxy Esta bloqueando el sitio , Conexión Denegada."
      echo "${verde}El proxy Esta bloqueando el sitio , Conexión Denegada." >> $file_evaluacion

    fi
    
    echo "${gris}Fecha y hora de evaluación " $(date) >> $file_evaluacion
    envio_maestro
   
    ;;
    4) exit;;
    "") echo "No haz seleccionado nada"
         ;; 
    *) echo "Opción no válida" ;;
     
esac

}
envio_maestro(){
carpeta_alumno=~/.mnt_nfs/$matricula
echo "${amarillo}----------------Envío de evaluación-----------------"
echo "${amarillo}Ingresa la dirección IP de la máquina del maestro"
read ip
ping -c 3 $ip 1>> /dev/null
if [ $? == 0 ]; then  
    sudo mount -t nfs $ip:/mnt/calificaciones ~/.mnt_nfs/ 2>>file_errores 1>>file_respuesta
    if [ $? == 0 ]; then 
      if [ -d "$carpeta_alumno" ]; then
      sudo cp $file_respuesta $carpeta_alumno
      sudo cp $file_evaluacion  $carpeta_alumno
      sudo cp $file_errores  $carpeta_alumno
      else
      cd ~/.mnt_nfs
      sudo mkdir $matricula
      sudo cp $file_respuesta  $carpeta_alumno
      sudo cp $file_evaluacion  $carpeta_alumno
      sudo cp $file_errores $carpeta_alumno
      fi
      sudo umount -l  ~/.mnt_nfs/ 2>>file_errores
    else
      echo "${rojo}No hay comunicación con el servidor NFS, Revisa tu conexión"
      echo "${amarillo} Tu dirección IP es:"  $ip_alumno
      echo "${amarillo}Los equipos deben estar en el mismo segmento de red"
    fi
else
echo "${rojo}No hay comunicación con el servidor NFS, Revisa tu conexión"
echo "${amarillo} Tu dirección IP es:"  $ip_alumno
echo "${amarillo}Los equipos deben estar en el mismo segmento de red"
fi
}

menu
