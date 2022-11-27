#!/bin/bash
rojo=`tput setaf 1`
amarillo=`tput setaf 3`
verde=`tput setaf 2`
blanco=`tput setaf 7`

instalacion(){
    if [ "$1" == "apache" ]; then
    servicio="apache2"

    elif [ "$1" == "dns" ];then
    servicio="bind9"
    fi
    cat /lib/systemd/system/"$servicio".service 1>> $file_respuesta 2>> $file_errores
    if [ $? == 0 ]; then
        echo "${verde} El servicio "$servicio" está instalado correctamente"
        echo "Servicio="$servicio"">> $file_evaluacion
	echo "Instalado=1" >> $file_evaluacion
    else
        echo "${rojo} El servicio "$servicio" no está instalado"
        echo "Servicio="$servicio"" >> $file_evaluacion
	echo "Instalado=0" >> $file_evaluacion
    fi
}

evaluacion(){
instalacion $servicio_web 
puerto $servicio_web $puerto_web
instalacion $servicio_dns
puerto $servicio_dns $puerto_dns


}

puerto(){
   #escucha=$(netstat -plnt 2>> $file_errores | grep $2 | awk {'print $6'})
   nc -z -v 127.0.0.1 $2 
   #if [ "$escucha" = "LISTEN" ]; then 
   if [ $? == 0 ]; then 
       echo "${verde} El servicio "$1" corriendo en el puerto "$2"" 
       echo "Puerto=1" >> $file_evaluacion

   else
       echo "${rojo} El servicio "$servicio" no está ejecutandose en el puerto "$2""
       echo "Puerto=0 " >> $file_evaluacion

fi
}
archivos(){
file_evaluacion=~/evaluacion/retroalimentacion-$1-$(date +"%d-%m-%Y").txt
file_errores=~/evaluacion/salidaerror-$1-$(date +"%d-%m-%Y").txt
file_respuesta=~/evaluacion/salida-$1-$(date +"%d-%m-%Y").txt



if [ -f $file_evaluacion ]
then
   echo ""
   
else

   touch $file_evaluacion
   echo "Matricula="$1>> $file_evaluacion
fi
}

 
menu() {

echo "ingresa tu matricula"
read matricula
archivos $matricula
echo "¿Qué actividad finalizaste?"
echo "1) Servidor Web "
echo "2) Servidor DNS "
echo "3)Servidor Proxy "
echo "4)Cancelar"
read opcion
case $opcion in
    1) echo -n "Evaluación servicio Web"
       echo -n "¿Está configurado en el puerto por defecto? 1. Si 2. No"
       read respuesta
      if [ "$respuesta" == "1" ]; then
        puerto="80"
        servicio="apache"
        instalacion $servicio
        puerto $servicio $puerto 
      else
        echo "¿En que puerto te fue solicitado?"
        read puerto_custom 
        puerto = $puerto_custom
        servicio = "apache"
        instalacion $servicio
        puerto $servicio $puerto 
     fi
    
    
    ;; 
    2) echo -n "Evaluación servicio DNS"
       echo -n "¿Está configurado en el puerto por defecto? 1. Si 2. No"
       read respuesta
      if [ "$respuesta" == "1" ]; then
        puerto="53"
        servicio="dns"
        instalacion $servicio
        puerto $servicio $puerto 
      else
        echo "¿En que puerto te fue solicitado?"
        read puerto_custom 
        puerto = $puerto_custom
        servicio = "dns"
        instalacion $servicio
        puerto $servicio $puerto 
     fi
    
    
    ;; 
esac
}

menu
