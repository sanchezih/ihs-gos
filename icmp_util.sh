#!/bin/bash
 
# Validar el argumento para la opción -C , debe ser un entero positivo.
# Validar el argumento para la opción -p , debe ser 4 o 6.
# Validar que el argumento host/ip sea una direccion ip o un hostname o dominio (ver
# caracteres aceptados para ambos casos).
# El script debe arrojar error si se omite el argumento hostname.
# El script debe recibir al menos una opción ademas del argumento host/ip.
# El script debe arrojar error si se pasan opciones incorrectas o inexistentes.
# Agregar una ayuda sobre el uso del script.
 
# Modo de uso:
#   ./icmp_util.sh -C n -D -p n -b <host>
#
# -C n      Numero de pings a realizar.
# -D        Imprimir timestamp.
# -p n      Protcolo a utilizar, 4 para ipv4 y 6 para ipv6.
# -b        Permite enviar paquetes a direcciones de broadcast.

#------------------------------------------------------------------------------#

function mostrar_ayuda()
{
	echo
	echo "Modo de uso:"
	echo "./icmp_util.sh -C n -D -p n -b <host>"
	echo
	echo "    -C n      Numero de pings a realizar."
	echo "    -D        Imprimir timestamp."
	echo "    -p n      Protcolo a utilizar, 4 para ipv4 y 6 para ipv6."
	echo "    -b        Permite enviar paquetes a direcciones de broadcast"  
}

# Funcion que valida si el parametro nro. 1 que recibe es una direccion ip valida
function validar_direccion_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Funcion que valida si el parametro nro. 1 que recibe es un nombre de dominio valido
function validar_nombre()
{
	validate="^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$"

	if [[ "$1" =~ $validate ]]; then
    	return 0
	else
	    return 1
	fi
}

# Funcion que valida si el parametro nro. 1 que recibe cumpla con lo pedido en el requerimiento
function validar_ultimo_param()
{
	validar_direccion_ip $1
	if [ $? -ne 0 ]; then
		validar_nombre $1
		if [ $? -ne 0 ]; then
			return 1
		else
			return 0
		fi
	else
		return 0
	fi
}

#------------------------------------------------------------------------------#

# Variable booleana que se modificara a false si se produce algun error en cualquiera de las validaciones que se haran
esta_todo_ok=true

cant_opciones=0
args=( $@ )

validar_ultimo_param ${args[-1]}
if [ $? -ne 0 ]; then
	esta_todo_ok=false
	echo "ERROR: Debe ingresar un host/ip/hostname/dominio valido"
	mostrar_ayuda
	exit 1
else
	for opcion in "${!args[@]}"; do
		
		case ${args[$opcion]} in

			-C)	cantidad=${args[$(($opcion+1))]}
				
				((cant_opciones=cant_opciones+1))

				# Valido que el numero sea entero positivo
				if ! [[ $cantidad =~ ^[0-9]+$ ]]  2> /dev/null; then
					echo "ERROR: Cantidad de pings no valida"
					esta_todo_ok=false
				fi

				counter="-c $cantidad"
	            ;;
	        
	        -T) timestamp="-D"
				
				((cant_opciones=cant_opciones+1))
	            ;;
			
			-p)	proto=${args[$(($opcion+1))]}

				((cant_opciones=cant_opciones+1))

				# Valido que el protocolo ingresado sea 4 o 6
				if ! [[ $proto -eq 4 || $proto -eq 6 ]]; then
					echo "ERROR: Protocolo invalido"
					esta_todo_ok=false
				fi

	            p="-$proto"
	            ;;
	        
	        -b)	b="-b"

				((cant_opciones=cant_opciones+1))
				;;

			# Valido que no se pasen opciones incorrectas o inexistentes.
			-*)	echo "ERROR: Alguna de las opciones ingresada es incorrecta"
				mostrar_ayuda
				exit 1
				;;

		esac
	done
fi

# Valido que se reciba al menos una opcion
if [ $cant_opciones -eq 0 ]; then
	echo "ERROR: El script debe recibir al menos una opcion ademas del argumento host/ip"
	mostrar_ayuda
	exit 1
fi

# Si luego de hacer todas las validaciones no veo que haya ningun problema, ejecuto el ping
if [ "$esta_todo_ok" = true ]; then
	echo "TODO OK!: Se va a ejecutar el comando ping"
	echo
	ping $b $timestamp $p $counter ${args[-1]}
else
	echo "ERROR: No se puede ejecutar el comando ping"
	mostrar_ayuda
	exit 1
fi
