#!/bin/bash

#Comprobación de argumentos. Debe ser >= a 2.

if [ $# -lt 2 ]
then
	echo "No se han introducido suficientes argumentos. error $0"
	exit 1
fi

#Comprobación de que primer argumento es un directorio

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
PARAMETROSNOITERADOS=0

PRIMERAITERACION=1

for o in $ORIGEN
do
	if [ $PRIMERAITERACION -eq 1 ]
	then 
		PRIMERAITERACION=0
		echo ""
		echo "-- Directorio a copiar los archivos: $o"
		echo ""
	else
		if ! [ -d $o ]
		then
			echo "ALERTA: $o no es un directorio, no se iterara sobre el"
			echo ""
			PARAMETROSNOITERADOS=$(expr $PARAMETROSNOITERADOS + 1)
		else
			echo "-------------------------------------"
			echo "Buscando archivos en: $o"
			echo "-------------------------------------"
			for ArchivoOrigen in $(ls -p $o | grep -v /)
			do
				ACTUALIZAR=0
				ArchivoDestino=$(find $DESTINO -type f -name $ArchivoOrigen)
				RESULTADO=0
				if ! [ -z $ArchivoDestino ]
				then
					#Cogemos las fechas y le ponemos un formato para poder ver cuál es menor ( más nueva )
					FECHAORIGEN=$(date +%F -r $o/$ArchivoOrigen | sed "s/-//g")
					FECHADESTINO=$(date +%F -r $ArchivoDestino | sed "s/-//g")
					RESULTADO=$(expr $FECHAORIGEN - $FECHADESTINO)
					if [ $RESULTADO -gt 0 ]
					then
						#La de origen es más nueva
						echo "Actualizando $ArchivoOrigen en $DESTINO"
						ACTUALIZAR=0
					else
						#La de destino es mas nueva o son iguales
						#Comparamos la hora de modificacion
						
						MODORIGEN=$(date -r $o/$ArchivoOrigen | cut -d " " -f 4 | sed "s/://g")
						MODDESTINO=$(date -r $ArchivoDestino | cut -d " " -f 4 | sed "s/://g")
						MODRESULTADO=$(expr $MODORIGEN - $MODDESTINO)
						
						if [ $MODRESULTADO -gt 0 ]
						then
							#Origen es mas nuevo
							echo "Actualizando $ArchivoOrigen en $DESTINO"
							ACTUALIZAR=0
						else
							#Destino es mas nueva o son iguales
							echo "$ArchivoOrigen ya se encuentra actualizado en $DESTINO"
							NOCOPIADOS=$(expr $NOCOPIADOS + 1)
							ACTUALIZAR=1
						fi
					fi
					
				fi					
				if [ $ACTUALIZAR -eq 0 ]	
				then
					echo "Copiando archivo: $ArchivoOrigen"
					cp -u --preserve=all $o/$ArchivoOrigen $DESTINO
					COPIADOS=$(expr $COPIADOS + 1)
				fi
			
			done
			echo ""
		fi
	fi
done

TOTAL=`expr $COPIADOS + $NOCOPIADOS`
echo "Total de ficheros iterados: $TOTAL, de los cuales copiados: $COPIADOS y no copiados: $NOCOPIADOS"
echo "Parametros erroneos en la llamada del script: $PARAMETROSNOITERADOS"
echo ""
if ! test $PARAMETROSNOITERADOS -eq 0
then
	exit 2
fi
exit 0


