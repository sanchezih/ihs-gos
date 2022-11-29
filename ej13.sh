#!/bin/bash

#-------------------------------------------------------------------------------
# funciones
#-------------------------------------------------------------------------------

function now() {
    date -u +"%Y-%m-%d_%H-%M-%S"Z
}

function create_dirlog() {
    if [ ! -d $log_dir ]; then
        mkdir $log_dir
    fi
}

function mostrar_menu(){
    clear
    echo "Bienvenido al script $0 (PID $$)"
    echo
    echo "Menu"
    echo "    1) Mostrar la ruta del directorio actual"
    echo "    2) Listar los links simbolicos de un directorio"
    echo "    3) Crear un directorio"
    echo "    4) Ver cantidad de nameservers en /etc/resolv.conf"
    echo "    5) Hacer backup"
    echo "    6) Generar auditoria de ingresos al sistema"
    echo "    q) Salir"
    echo "---------------------------------------------------------------------"
}

function salir_saludando(){
    NOMBRE=$1 # Guardo el parametro nro. 1 que recibe la funcion
    echo
    echo "Chau $NOMBRE"
    echo "Saliendo..."
    sleep 2
}

#-------------------------------------------------------------------------------
# programa principal
#-------------------------------------------------------------------------------

OPCION=0
mostrar_menu
while true; do
    read -p "Ingrese una opcion (m para mostrar el menu): " OPCION # Mensaje y read en la misma linea
 
    case $OPCION in
        1)  echo "-> El directorio actual es:" `pwd`
            ;;

        ########################################################################

        2)  echo "Ingrese el nombre del directorio:"
            read NOMBRE_DIR

            if [ -d "$NOMBRE_DIR" ]; then
                find $NOMBRE_DIR -maxdepth 1 -type l
            else
                echo "ERROR: El directorio no existe"
            fi
            ;;
        
        ########################################################################

        3)  read -p "Ingrese el nombre del directorio a crear: " NOMBRE_DIR
            mkdir $NOMBRE_DIR 2>/dev/null # Envio a la nada el retorno de mkdir

            if [ $? -ne 0 ]; then
                echo "ERROR: No se puede crear el directorio $NOMBRE_DIR"
            else
                echo "OK!: El directorio $NOMBRE_DIR fue creado con exito"
            fi
            ;;

        ########################################################################

        4)  for file in /etc/*
            do
                if [ "${file}" == "/etc/resolv.conf" ]
                then
                    countNameservers=$(grep -c nameserver /etc/resolv.conf)
                    echo "Hay ${countNameservers} nameservers definidos en ${file}"
                    break
                fi
            done
            ;;

        ########################################################################

        5)  base_name=$(basename -- "$0")
            log_dir=~/$base_name'_'logs

            create_dirlog
            if [ $? -ne 0 ]; then
                echo "ERROR: No se puede crear el directorio de logs"
            elif [[ -z "${BACKUP_DIR}" ]]; then
                echo "ERROR: El directorio destino no esta seteado como variable de entorno"
            else
                logfile=$log_dir/$base_name'_'`now`.log

                read -p "Ingrese la ruta del directorio que quiere backupear: " DIR_A_BACKUPEAR

                if [ ! -d "$DIR_A_BACKUPEAR" ]; then
                    echo "ERROR: Directorio incorrecto"
                else
                    read -p "Quiere indicar un archivo con el listado de las cosas a excluir? (s/n) " CON_EXCLUDE

                    case $CON_EXCLUDE in
                        s)  echo "se hara con exclude"
                            read -p "Ingrese la ruta del archivo: " ARCHIVO_EXCLUDE
                            if [ ! -f "$ARCHIVO_EXCLUDE" ]; then
                                echo "ERROR: ARCHIVO_EXCLUDE incorrecto"
                            else
                                rsync -vtr --out-format="%t %f %'''b" --stats -h --delete --exclude-from=$ARCHIVO_EXCLUDE $DIR_A_BACKUPEAR $BACKUP_DIR >> $logfile 2>&1
                            fi
                        ;;

                        n)  echo "Se hara backup sin archivo exclude"
                            echo "Origen: $DIR_A_BACKUPEAR"
                            echo "Destino: $BACKUP_DIR"
                            
                            rsync -vtr --out-format="%t %f %'''b" --stats -h --delete $DIR_A_BACKUPEAR $BACKUP_DIR >> $logfile 2>&1
                        ;;

                        *)  echo "ERROR: Opcion incorrecta"
                        ;;
                    esac
                fi
            fi
            ;;

        ########################################################################

        6)  login_todos="/tmp/listado-de-ingresos.txt"
            login_root="/tmp/listado-de-ingresos-root.txt"

            last | tee $login_todos | grep root > $login_root
            ;;

        ########################################################################

        m)  mostrar_menu
            ;;

        q)  salir_saludando `whoami` # Ejecuto whoami y el resultado se lo paso a la funcion
            break
            ;;

        *)  echo "ERROR: Opcion incorrecta";;
    esac
done
exit 0


