#!/bin/bash
#variables de color
blue=$(tput setaf 4)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
normal=$(tput sgr0)


if [ "$EUID" -ne 0 ]
  then echo -e "\e[31mParece que no tenes los permisos necesarios, tal vez un "sudo" ayude?\e[0m"
  exit
fi

inicio()
{
echo ""
echo -e "\e[34mEste script ayuda a la creacion de contenedores y configuraciones necesarias para la plataforma de sftp.\e[0m"
echo ""
echo -e "\e[34mA continuacion voy a hacer una lista de los datos que voy a solicitarte, asegurate de tenerlos a mano.\e[0m"
echo ""
echo ""
echo -e "\e[33m1. Una carpeta compartida en formato SMB/CIFS (se usara para exportar los perfiles de clientes)\e[0m"
echo ""
echo -e "\e[33m2. Un usuario con permisos de escritura para el share anteriormente mencionado\e[0m"
echo ""
#echo -e "\e[33m3. El dominio en el cual se daran de alta los registros '"A"' que haran referncia a las IP publicas por las cuales se conectaran los clientes\e[0m"
echo ""
echo ""
echo ""
read -p $'\e[34mTenes listo y a mano todo eso? (y/n) \e[0m' yn
case $yn in
        [Yy]* ) datos_winshare;;
		[Nn]* ) echo -e "\e[31mEjecutame nuevamente cuando tengas todo\e[0m" && exit;;
        * ) echo -e "\e[31mPor favor responda y o n .\e[0m";;
    esac
}
	
datos_winshare()
{
echo ""
echo -e "\e[34mOK, comencemos,primero voy a necesitar algunos datos:\e[0m"
echo ""
echo -e "\e[34mRuta completa de carpeta compartida para copiar los accesos, en el formato //IP/ruta/de/share\e[0m"
echo -e "\e[31mMuy importante respetar el formato y la ruta, todavia no soy tan inteligente y si hechas moco la vuelta atras va a ser muy engorrosa\e[0m"
printf "${yellow}RUTA:${normal}"
read -r sharepath
echo -e "\e[34musuario con permisos de escritura para $sharepath, solo usuario, sin dominio\e[0m"
printf "${yellow}USER:${normal}"
read -r user
printf "${yellow}PASSWD:${normal}"
read -r passwd
echo ""
confirmar_datos_winshare
}

confirmar_datos_winshare()
{
echo -e "\e[34mOK, los datos ingresados son los siguientes\e[0m"
echo -e "\e[32mRuta de destino:\e[0m$sharepath"
echo -e "\e[32mUsuario:\e[0m$user"
echo -e "\e[32mPassword:\e[0m$passwd"
read -p $'\e[34mLos datos son correctos? (y/n) \e[0m' yn
case $yn in
        [Yy]* ) buildear_imagenes;;
		[Nn]* ) echo -e "\e[31mOk corrijamos entonces\e[0m" && datos_winshare;;
        * ) echo -e "\e[31mPor favor responda y o n .\e[0m";;
    esac
}

buildear_imagenes()
{
echo -e "\e[34mAhora a buildear las imagenes necesarias, una es un cifs para poder hablar con el windows, una base de sqlite para llevar control de las empresas creadas y el ultimo el sftp server\e[0m"
sleep 4
echo -e "\e[34mVas a ver mucho output, no entres en panico, todo esta bajo control.\e[0m"
sleep 3
echo -e "\e[34mListo? GO!\e[0m"
sleep 1
# build cifs image
docker build -t procom/sftp.cifs --build-arg WINSHARE_PATH=$sharepath  --build-arg USER=$user --build-arg PASSWD=$passwd ./cifs/.
# build sqlite image
docker build -t procom/sftp.db ./sqlite/.
# build sftp image
docker build -t procom/sftp ./sftp-server/.
# run db container
docker run -d --name=sftp.db --restart unless-stopped procom/sftp.db
# run cifs container
docker run -d -v sftp.cifs:/mnt/openvpn --name=sftp.cifs --privileged --cap-add=MKNOD --cap-add=SYS_ADMIN --device=/dev/fuse --restart unless-stopped procom/sftp.cifs
# copiar script de openvpn
cp ./sftp-server/sftp.bash /usr/bin/sftp
chmod +x /usr/bin/sftp
gestor
}

gestor()
{
echo ""
echo -e "\e[34mVoy a crear un usuario gestor que solo pueda ejecutar el script para administrar los contenedores\e[0m"
printf "${yellow}USER:${normal}"
read -r gestor
printf "${yellow}PASSWD:${normal}"
read -r gestorpasswd
sudo adduser $gestor --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$gestor:$gestorpasswd" | chpasswd
echo -e "\e[34mAhora a enjaularlo en el script, para que solo tenga acceso a eso\e[0m"
sleep 2
echo "Match User $gestor" >> /etc/ssh/sshd_config
echo "		ForceCommand /usr/bin/sftp" >> /etc/ssh/sshd_config
usermod -aG docker $gestor
echo -e "\e[34mTengo que reiniciar el servicio de ssh para que los cambios tomen efecto, tranquilo no va a pasar nada\e[0m"
sleep 2
/etc/init.d/ssh restart
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
echo -e "\e[32mtodo listo, ya podes ingresar a este servidor con el usuario $gestor y comenzar a trabajar.\e[0m"
}

inicio