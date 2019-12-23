#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

# Generate CA key
openssl req -new -x509 -keyout snakeoil-ca-1.key -out snakeoil-ca-1.crt -days 365 -subj '/CN=ca1.syslog-test.local/OU=./O=./L=./S=./C=US' -passin pass:test1234 -passout pass:test1234
# openssl req -new -x509 -keyout snakeoil-ca-2.key -out snakeoil-ca-2.crt -days 365 -subj '/CN=ca2.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US' -passin pass:confluent -passout pass:confluent


for i in kafka producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i.syslog-test.local, OU=TEST, O=, L=, S=, C=US" \
				 -keystore $i.keystore.jks \
				 -keyalg RSA \
				 -storepass test1234 \
				 -keypass test1234

	# Create CSR, sign the key and import back into keystore
	keytool -keystore $i.keystore.jks -alias $i -certreq -file $i.csr -storepass test1234 -keypass test1234

	openssl x509 -req -CA snakeoil-ca-1.crt -CAkey snakeoil-ca-1.key -in $i.csr -out $i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:test1234

	keytool -keystore $i.keystore.jks -alias CARoot -import -file snakeoil-ca-1.crt -storepass test1234 -keypass test1234 -noprompt

	keytool -keystore $i.keystore.jks -alias $i -import -file $i-ca1-signed.crt -storepass test1234 -keypass test1234 -noprompt

	# Create truststore and import the CA cert.
	keytool -keystore $i.truststore.jks -alias CARoot -import -file snakeoil-ca-1.crt -storepass test1234 -keypass test1234 -noprompt

  echo "test1234" > creds
done