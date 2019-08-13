# /bin/ash
tput clear

main_menu()
{
until [ option = 0 ]; do
unset empresa
read -p "
============================
1.) Listar empresas
2.) Listar accesos
3.) Alta empresa
4.) Alta acceso
5.) Baja acceso
6.) Limpiar consola
7.) Habilita IP
8.) Alta acceso bulk
9.) Listar clientes conectados
0.) Exit
Enter choice: " option
echo
case $option in

    1) lista_empresas;;
    2) lista_accesos;;
    3) alta_empresa;;
    4) alta_acceso;;
    5) baja_acceso;;
    6) limpia_consola;;
    7) habilita_ip;;
    8) alta_acceso_bulk;;
    9) lista_conectados;;
    10) detalle_empresas;;
    0) exit;;
    *) echo -e "\e[31mPor favor ingrese una opcion valida\e[0m";;

esac
done
}

lista_empresas()
{
docker exec -it sftp.db sqlite3 /database/sftp.db '.header on' '.mode column' '.width 60, 6' 'SELECT nombre, puerto FROM empresa;'
main_menu
}

lista_accesos()
{
echo -e "\e[34m================ Lista Accesos ================\e[0m"
echo ""
echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
read empresa
if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
        then
				#docker run -v $empresa.sftp:/etc/sftp --rm -it kylemanna/sftp ovpn_listclients
                # COMANDO PARA LISTAR USUARIOS CREADOS SOBRE /ETC/PASSWD
echo ""
echo echo -e "\e[34m================ Accesos ================\e[0m"                
                docker exec -it $empresa.sftp /bin/sh -c "ls /home"
				main_menu
        else
				echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
fi
}

alta_empresa()
{
echo -e "\e[34m================ Alta Empresa ================\e[0m"
echo ""
echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
read empresa
echo -e "\e[34mIngrese el puerto asignado a $empresa: \e[0m"
read port


if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
        then
                echo -e "\e[31mla empresa $empresa ya se encuentra dada de alta.\e[0m"
        else
                if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE puerto='$port' COLLATE NOCASE);" | grep -q '1';
                        then
                                echo -e "\e[31mel puerto $port ya se encuentra utilizado por otra empresa.\e[0m"
                        else
                                alta_empresa_sftp
                fi
fi
}

alta_empresa_sftp ()
{

echo -e "\e[33mCreando contenedor de servicio sftp\e[0m"
docker run -d \
--name $empresa.sftp \
--cap-add=NET_ADMIN \
-v $empresa.sftp.home:/home \
-v $empresa.sftp.cfg:/etc/ssh \
-p $port:22 \
--restart unless-stopped \
procom/sftp

# Add iptables rules to this container, we accept only servers specified, everything else is dropped
docker exec -d $empresa.sftp /bin/ash -c "iptables -i eth0 -A INPUT -j DROP"

# save those iptables changes
docker exec -d $empresa.sftp /bin/ash -c "iptables-save > /etc/ssh/iptables.rules.v4"

docker exec -it sftp.db sqlite3 /database/sftp.db "INSERT INTO EMPRESA (NOMBRE,PUERTO) VALUES ('$empresa', '$port');"

# Esto hace algo, todavia no se que.
#docker run -v ovpn.sftp:/perfiles --rm -it alpine sh -c "mkdir /perfiles/$empresa" && docker exec ovpn.sftp /bin/sh -c "rsync -a /mnt/sftp/ /mnt/winshare"

# restart container to apply changes
docker restart $empresa.sftp

}


alta_acceso()
{
echo -e "\e[34m================ Alta Acceso ================\e[0m"
echo ""
echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
read empresa
echo -e "\e[34mIngrese el numero de acceso: \e[0m"
read acceso
if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
        then
        ## script para crear usuario y todo lo necesario
        docker exec -it $empresa.sftp /bin/sh -c "/addUser.sh $acceso"
        ## FALTA SYNC DE LLAVES A REPOSITORIO EXTERNO/FILESERVER
else
                echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
fi
}

baja_acceso()
{
echo -e "\e[34m================ Baja Acceso ================\e[0m"
echo ""
echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
read empresa
echo -e "\e[34mIngrese el numero de acceso: \e[0m"
read acceso
if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
        then
read -p $'\e[31mVoy a dar de baja el acceso indicado estas seguro? (y/n) \e[0m' yn
    case $yn in
        [Yy]* ) docker exec -it $empresa.sftp /bin/sh -c "mv /home/$acceso/.ssh/authorized_keys /home/$acceso/.ssh/authorized_keys.revoked";;
	[Nn]* ) echo -e "\e[31mTarea cancelada\e[0m" && exit;;
        * ) echo -e "\e[31mPor favor responda y o n .\e[0m";;
    esac
        else
                echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
fi
}

limpia_consola()
{
tput clear
}

habilita_ip()
{
echo -e "\e[34m================ Habilita IP ================\e[0m"
echo ""
if [ -z "$empresa" ];
        then
                echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
				read empresa
				if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
					then
						habilita_ip
					else
						echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
						main_menu
			    fi 
        else
                echo -e "\e[34mIngrese ip desde donde permitira la conexiones a $empresa (ej: 181.13.22.15): \e[0m"
                read ippriv
                echo -e "\e[34mIngrese la mascara para la subred definida (ej: 255.255.255.0): \e[0m"
                read mask
                docker exec -d $empresa.sftp /bin/ash -c "iptables -i eth0 -I INPUT 1 -s $ippriv/$mask -j ACCEPT"
                echo -e "\e[34mQuiere agregar otro servidor a $empresa? (y/n): \e[0m"
fi
read answer
if echo "$answer" | grep -iq "^y" ;then
    habilita_ip
else
   echo "Guardando cambios en iptables..." ; 
   docker exec -d $empresa.sftp /bin/ash -c "iptables-save > /etc/ssh/iptables.rules.v4" ;     
   sudo netfilter-persistent save ;
   echo -e "\e[31mSus cambios no surtiran efecto hasta que el contenedor de $empresa sea reinciado. Desea reiniciarlo ahora? CUIDADO! esto desconectara a los usuarios de $empresa momentaneamente (y/n)\e[0m"
   read answer
                if echo "$answer" | grep -iq "^y" ;then
						docker restart $empresa.sftp
						main_menu
                else
						echo -e "\e[31mReinicio no efectuado. Recuerde que sus cambios no surtiran efecto hasta tanto reinicie el contenedor\e[0m"
						main_menu
				fi
fi
}

alta_acceso_bulk()
{
echo -e "\e[34m================ Alta Acceso Bulk ================\e[0m"
echo -e "\e[31m================ ESTA OPCION NO SE ENCUENTRA DISPONIBLE EN ESTA VERSION, POR FAVOR ENVIE UN CORREO A GGABAS@PROCOMARGENTINA.COM SOLICITANDOLO ================\e[0m"
main_menu
#echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
#read empresa
#echo -e "\e[34mIngrese el primer numero de acceso: \e[0m"
#read primer_acceso
#echo -e "\e[34mIngrese el utlimo numero de acceso: \e[0m"
#read ultimo_acceso
#if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
#        then
#                read -p $'\e[34mQuiere que el perfil solicite password? (y/n): \e[0m' yn
#    case $yn in
#        [Yy]* ) for i in $(seq $primer_acceso $ultimo_acceso); do docker run -v $empresa.sftp:/etc/sftp --rm -it kylemanna/sftp easyrsa build-client-full $empresa-$i ; done;;
#        [Nn]* ) for i in $(seq $primer_acceso $ultimo_acceso); do docker run -v $empresa.sftp:/etc/sftp --rm -it kylemanna/sftp easyrsa build-client-full $empresa-$i nopass ; done;;
#        * ) echo -e "\e[31mPor favor responda y o n .\e[0m";;
#    esac
#                for i in $(seq $primer_acceso $ultimo_acceso); do docker run -v ovpn.sftp:/perfiles -v $empresa.sftp:/etc/sftp -v sftp.files.bin:/usr/local/bin --rm -it kylemanna/sftp ovpn_getclient $empresa-$i combined-save ; done && docker exec ovpn.sftp /bin/sh -c "rsync -a /mnt/sftp/ /mnt/winshare"
#        else
#                echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
#fi
}

lista_conectados()
{
echo -e "\e[34m================ Lista Conectados ================\e[0m"
echo ""
echo -e "\e[34mIngrese nombre de la empresa: \e[0m"
read empresa
if docker exec -it sftp.db sqlite3 /database/sftp.db "SELECT EXISTS(SELECT 1 FROM empresa WHERE nombre='$empresa' COLLATE NOCASE);" | grep -q '1';
        then
# ALGUNA FORMA DE LISTAR USAURIOS SFTP CONECTADOS
main_menu
        else
                echo -e "\e[31mla empresa $empresa no se encuentra dada de alta.\e[0m"
fi
}


main_menu