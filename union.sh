#!/bin/bash

#Comprobacion de argumentos. Debe >= a 2.

if [ $# -lt 2 ]
then
	echo "No se han introducido suficientes argumentos. error $0"
	exit 1
fi

#Comprobacion de que primer argumento es un directorio

if [ -d $1 ]
then
	DESTINO=$1
else
	echo "El argumento $1 (destino) no es un directorio o no se ha encontrado"
	exit 1
fi

#Metemos en una lista los directorios origen para poder recorrerlos

ORIGEN=$@

#Contamos los copiados y los no copiados para ofrecer información

COPIADOS=0
NOCOPIADOS=0

PRIMERAITERACION=1

for i in $ORIGEN
do
	if [ $PRIMERAITERACION -eq 1 ]
	then 
		PRIMERAITERACION=0
		echo ""
		echo "-- Directorio a copiar los archivos: $i"
		echo ""
	else
		if ! [ -d $i ]
		then
			echo "ALERTA: $i no es un directorio, no se iterara sobre el"
			echo ""
			NOCOPIADOS=$(expr $NOCOPIADOS + 1)
		else
			echo "-------------------------------------"
			echo "Buscando archivos en: $i"
			echo "-------------------------------------"
			for ARCHIVE in $(ls -p $i | grep -v /)
			do
				ACTUALIZAR=0
				EXISTE=$(find $DESTINO -type f -name $ARCHIVE)
				RESULTADO=0
				if ! [ -z $EXISTE ]
				then
					#Cogemos las fechas y le ponemos un formato para poder ver cual es menor ( mas nueva )
					FECHAORIGEN=$(date +%F -r $i/$ARCHIVE | sed "s/-//g")
					FECHADESTINO=$(date +%F -r $EXISTE | sed "s/-//g")
					RESULTADO=$(expr $FECHAORIGEN - $FECHADESTINO)
					if [ $RESULTADO -gt 0 ]
					then
						#La de origen es más nueva
						echo "Actualizando $ARCHIVE en $i"
						ACTUALIZAR=0
					else
						#La de destino es más nueva o son iguales
						echo "$ARCHIVE ya se encuentra actualizado en $i"
						NOCOPIADOS=$(expr $NOCOPIADOS + 1)
						ACTUALIZAR=1
					fi
				fi
				if [ $ACTUALIZAR -eq 0 ]	
				then
					echo "Copiando archivo: $ARCHIVE"
					cp -u --preserve=all $i/$ARCHIVE $DESTINO
					COPIADOS=$(expr $COPIADOS + 1)
				fi
			
			done
			echo ""
		fi
	fi
done

TOTAL=`expr $COPIADOS + $NOCOPIADOS`
echo "Total de ficheros: $TOTAL, de los cuales copiados: $COPIADOS y no copiados: $NOCOPIADOS"

exit 0


