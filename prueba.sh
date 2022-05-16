#!/bin/bash
rojo=`tput setaf 1`
amarillo=`tput setaf 3`
verde=`tput setaf 2`
blanco=`tput setaf 7`
#script  -B apacheactividad 
function saludo(){
echo " ${amarillo}***Evaluacion de la práctica APACHE******"
echo " ${amarillo}Tienes en la carpeta home la carpeta con los archivos necesarios para instalar apache por el método de compilación. "
echo " ${amarillo} Se espera que: 1)Instales apache por el método de compilación "
echo " ${amarillo}                2)Ingreses el comando para el inicio del servicio"
echo " ${amarillo}                3)Configures en el puerto 8080"
echo " ${amarillo}                4)Crea una página web con tu nombre"
}

function instalacion(){
dpkg -l | grep $1
if [ $? == 0 ]; then
    echo "${verde} $1 instalado correctamente"
    punt1=10
else
    echo "${rojo}$1 no está instalado"
    punt1=0
fi
}
function puerto(){
sudo netstat -tulpn | grep $2 
if [ $? == 0 ]; then
    echo "${verde}Está corriendo en el puerto $2"
    punt2=10
else
    echo "${rojo}Apache no está en el puerto $2"
    punt2=0
fi
#return punt2
}

function evaluacion(){
punt1=0
punt2=0
puntf=0
saludo
instalacion
puerto
puntf=$((punt1+punt2))
echo "${blanco}Tu puntuacion es:"  $puntf
}


evaluacion
