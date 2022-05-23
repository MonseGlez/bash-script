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
cat /lib/systemd/system/"$servicio".service 1>> stout.log 2>> stderr.log

if [ $? == 0 ]; then
    echo "${verde} El servicio "$servicio" está instalado correctamente"
    punt1=10
else
    echo "${rojo} El servicio "$servicio" no está instalado"
    punt1=0
fi
return $punt1
}

directorio(){
    echo "${amarillo} Ingresa tu nombre, recuerda que tu nombre deberá estar configurado el virtual host en apache"
    read nombre       
    apache2ctl -S 2> stderr.log| grep -o -E 'alias (.*)|(namevhost|server) (.*)\s' | cut -d ' ' -f 2 | grep "$nombre" 
    if [ $? == 0 ]; then
    echo "${verde} El servicio "$servicio" esta configurado en el virtual host mostrado anteriormente" 
    punt4=10
    else
    echo "${rojo} No existe el virtual host con tu nombre, a continuación verás los virtual host que configuraste : "
    apache2ctl -S 2>stderr.log| grep -o -E 'alias (.*)|(namevhost|server) (.*)\s' | cut -d ' ' -f 2

    
    fi
             
return $punt4
}

puerto(){

escucha=$(netstat -plnt 2>> stderr.log | grep $2 | awk {'print $6'})

if [ "$escucha" = "LISTEN" ]; then 
    echo "${verde} El servicio $1 corriendo en el puerto $2"
    punt2=10
else
    echo "${rojo} El servicio $1 no está en el puerto $2"
    punt2=0
fi
return $punt2
}


evaluacion(){

punt1=0
punt2=0
punt3=0
punt4=0

puntf=0
instalacion $1
puerto $1 $2
directorio  
echo $3
puntf=$((punt1+punt2+punt3+punt4))
echo "${blanco}Tu puntuacion es:"  $puntf
}

evaluacion $1 $2
