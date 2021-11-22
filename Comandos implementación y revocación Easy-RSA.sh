#En el servidor
mkdir /home/$USER/ca

mkdir /home/$USER/ca/easy-rsa/

#Creación del enlace simbólico
ln -s /usr/share/easy-rsa/* /home/$USERca/easy-ras/

chmod -R 744 /home/$USER/ca

/home/$USER/ca/easy-rsa/easyrsa init-pki 

echo '

set_var EASYRSA_REQ_COUNTRY	"ES"
set_var EASYRSA_REQ_PROVINCE	"Castellón"
set_var EASYRSA_REQ_CITY	"Castellón"
set_var EASYRSA_REQ_ORG	"LAPLANA"
set_var EASYRSA_REQ_EMAIL	"alufon090@ieselcaminas.org"
set_var EASYRSA_REQ_OU		"Dep-Hospital"
set_var EASYRSA_ALGO		"ec"
set_var EASYRSA_DIGEST		"sha512"

' > /home/$USER/ca/easy-rsa/easyrsa/vars

/home/$USER/ca/easy-rsa/easyrsa build-ca

#Ponemos una contraseña segura (servirá para revocar o firmar un certificado) :)

#Intro

#En el cliente
scp administrador@192.168.1.92:/home/administrador/ca/easy-rsa/pki/ca.crt /home/sergio/Documentos

sudo cp /home/sergio/Documentos/ca.crt /usr/local/share/ca-certificates

sudo update-ca-certificates

mkdir /home/sergio/Documentos/prueba-csr


openssl genrsa -out irelia-server.key
openssl req -new -key irelia-server.key -out  irelia-server.req
openssl req -in irelia-server.req -noout -subject (Comprobación)

scp irelia-server.req administrador@192.168.1.92:/home/administrador/irelia-server.req

#En el servidor
cd ca/easy-rsa
./easyrsa import-req ../../irelia-server.req irelia-server
./easyrsa sign-req server irelia-server

#Revocar un certificado
./easyrsa revoke irelia-server
# Revoking Certificate 9268C25DB7DDECF1CE7D1DBF7CE52465

#Generar lista de revocación
./easyrsa gen-crl

#Transferencia a cliente
#Desde el cliente
scp administrador@192.168.1.92:/home/administrador/ca/easy-rsa/pki/crl.pem /tmp

#Comprobación en cliente
openssl crl -in /tmp/crl.pem -noout -text

#Comprobación en server
openssl crl -in pki/crl.pem -noout -text

#Comprobación con grep
openssl crl -in /tmp/crl.pem -noout -text | grep -A 1 9268C25DB7DDECF1CE7D1DBF7CE52465


