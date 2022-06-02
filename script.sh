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
    echo "El servicio "$servicio" está instalado correctamente"
    punt1=10
else
    echo " El servicio "$servicio" no está instalado"
    punt1=0
fi
return $punt1
}

directorio(){
       
    apache2ctl -S | grep -o -E 'alias (.*)|(namevhost|server) (.*)\s' | cut -d ' ' -f 2 | grep $NOMBRE
    if [ $? == 0 ]; then
    a2query -s| grep $NOMBRE  | xargs -L1 -I %  zenity --width=250 --height=250 --info --text=% 

    echo "$El servicio "$servicio" esta configurado en el virtual host mostrado anteriormente" 
    punt4=10
    else
    zenity --error --text "No existe el virtual host con tu nombre, a continuación verás los virtual host que configuraste :"
    a2query -s | xargs -L1 -I %  zenity --width=250 --height=250 --info --text=% 



    
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

menu(){
    NOMBRE=$(zenity --entry --title="Nombre de Alumno" --text="Introduce tu nombre")
    zenity --info --title="Evaluación automática" --width=250  --text="Se mostrará un menú para seleccionar el servicio a evaluar."
    OPCION="0"
    until [ $OPCION == "3" ]
    do
    OPCION=$(zenity --list --title="Seleccione la opción a ejecutar" --column="Id" --column="Opcion" 1 "Evaluar servicio APACHE" 2 "Evaluar servicio DNS" 3 "Salir")
    case $OPCION in

    1) servicio='apache'
       puerto='80'
       instalacion $servicio $puerto | xargs -L1 -I %  zenity --width=250 --height=250 --info --text=% 
        
       directorio $NOMBRE $servicio |  xargs -L1 -I %  zenity --width=250 --height=250 --info --text=% 


       ;;

    2) servicio='dns'
       puerto='53'
       instalacion $servicio $puerto | xargs -L1 -I %  zenity --width=250 --height=250 --info --text=%
       ;;
    esac
    done
     

    

    




}
menu
#evaluacion $1 $2
