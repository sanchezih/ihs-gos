#!/bin/bash
 
# Validar el argumento para la opción -C , debe ser un entero positivo.
# Validar el argumento para la opción -p , debe ser 4 o 6.
# Validar que el argumento host/ip sea una direccion ip o un hostname o dominio (ver
# caracteres aceptados para ambos casos).
# El script debe arrojar error si se omite el argumento hostname.
# El scritp debe recibir al menos una opción ademas del argumento host/ip.
# El script debe arrojar error si se pasan opciones incorrectas o inexistentes.
# Agregar una ayuda sobre el uso del script.
 
# Modo de uso:
#   ./icmp_util.sh -C n -D -p n -b <host>
#
# -C n      Numero de pings a realizar.
# -D        Imprimir timestamp.
# -p n      Protcolo a utilizar, 4 para ipv4 y 6 para ipv6.
# -b        Permite enviar paquetes a direcciones de broadcast.
 
args=( $@ )
 
for opcion in "${!args[@]}"; do
 
    case ${args[$opcion]} in
 
        -C)     cantidad=${args[$(($opcion+1))]}
            counter="-c $cantidad"
            ;;
        -T) timestamp="-D"
            ;;
        -p)     proto=${args[$(($opcion+1))]}
            p="-$proto"
            ;;
        -b)     b="-b"
            ;;
    esac
done
 
ping $b $timestamp $p $counter ${args[-1]}