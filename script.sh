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
        echo " El servicio "$servicio" está instalado correctamente" >> $file_evaluacion

        punt1=10
    else
        echo "${rojo} El servicio "$servicio" no está instalado"
        echo " El servicio "$servicio" no está instalado" >> $file_evaluacion

        punt1=0
    fi
    return $punt1
}



puerto(){

escucha=$(netstat -plnt 2>> $file_errores | grep $2 | awk {'print $6'})

if [ "$escucha" = "LISTEN" ]; then 
    echo "${verde} El servicio $1 corriendo en el puerto $2" 
    echo "El servicio $1 corriendo en el puerto $2" >> $file_evaluacion

    punt2=10
else
    echo "${rojo} El servicio $1 no está ejecutandose en el puerto $2"
    echo "El servicio $1 no está ejecutandose en el puerto $2" >> $file_evaluacion

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
puntf=$((punt1+punt2+punt3+punt4))
echo "${blanco}Tu puntuacion es:"  $puntf
echo "Tu puntuacion es:"  $puntf "Final de evaluacion"  >> $file_evaluacion

}
modo_uso(){
echo "El modo de uso esperado es:  ./script nombre_servicio puertoesperado  por ejemplo: ./script apache 80"
}
modo_uso
echo "ingresa tu matricula"
read matricula
file_evaluacion=/home/monse/evaluacion/retroalimentacion-$matricula-$(date +"%d-%m-%Y").txt
file_errores=/home/monse/evaluacion/salidaerror-$matricula-$(date +"%d-%m-%Y").txt
file_respuesta=/home/monse/evaluacion/salida-$matricula-$(date +"%d-%m-%Y").txt


if [ -f $file_evaluacion ]
then
   echo "Ya está creado el fichero, saltando creacion" 
   date
else
   echo "El fichero no existe, creando"

   touch $file_evaluacion

fi



evaluacion $1 $2




