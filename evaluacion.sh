#!/bin/bash
rojo=`tput setaf 1`
amarillo=`tput setaf 3`
verde=`tput setaf 2`
blanco=`tput setaf 7`
servicio_web="apache"
servicio_dns="dns"
puerto_web="80"
puerto_dns="53"

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


evaluacion(){
instalacion $servicio_web 
puerto $servicio_web $puerto_web
instalacion $servicio_dns
puerto $servicio_dns $puerto_dns


}
#modo_uso(){
#echo "El modo de uso esperado es:  ./script nombre_servicio puertoesperado  por ejemplo: ./script apache 80"
#}

#modo_uso
echo "ingresa tu matricula"
read matricula
file_evaluacion=~/evaluacion/retroalimentacion-$matricula-$(date +"%d-%m-%Y").txt
file_errores=~/evaluacion/salidaerror-$matricula-$(date +"%d-%m-%Y").txt
file_respuesta=~/evaluacion/salida-$matricula-$(date +"%d-%m-%Y").txt


if [ -f $file_evaluacion ]
then
   echo ""
   #echo "Ya está creado el fichero, saltando creacion" 
   #date
else
   echo "El fichero no existe, creando"

   touch $file_evaluacion
   echo "Matricula="$matricula>> $file_evaluacion
fi



evaluacion $1 $2
file_csv=~/evaluacion/formatt.csv
#touch $file_csv


for F in $file_evaluacion
do
    {
        read Matricula
        read Servicio
        read Puerto

    }< $F
    echo "$Matricula,$Servicio,$Puerto" >> $file_csv

done



