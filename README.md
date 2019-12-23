# rsyslog-kafka docker-compose setup

This is a docker-compose setup for rsyslogd and kafka using GSSAPI with SASL_SSL (TLS + kerberos) for testing purposes  
most data is from https://docs.confluent.io/4.0.0/installation/docker/docs/tutorials/clustered-deployment-sasl.html
using github source: https://github.com/confluentinc/cp-docker-images/examples/kafka-cluster-sasl
kerberos setup comes from https://github.com/ist-dsi/docker-kerberos

# Setup

The setup is as follows;
- kdc-admin             for handing out tickets
- kerberos-client       to generate tickets for kafka, the consumer and producer
- kafka                 as message broker
- kafka-create-topics   to generate topic, using PLAINTEXT protocol over port 9092
- omkafka_gssapi        for producing (syslog)messages on the kafka topic, using SASL_SSL on port 9094
- imkafka_gssapi        for consuming (syslog)messages from the kafka topic, using SASL_SSL on port 9094
- volume:./private      for hosting all config and key material

File                            | Purpose
----                            | -------
*.keytab,                       | used for client/server authentication
host_krb.conf,                  | used for general kerberos(krb5.conf) config, shared by all containers 
*.jaas.conf,                    | used for kafka, test-producer, test-consumer kerberos configuration
*.ssl.sasl.conf,                | used for test-producer and test-consumer ssl and SASL configuration
truststores,                    | used for storing kafka, test-producer and test-consumer public-key material
keystores,                      | used for storing kafka, consumer and producer ssl private keys
ca*.crt certificate(PEM)        | used to sign/check certificates against 
client *.crt certificates(PEM)  | used to enable ssl communication on rsyslogd hosts

# Getting started

generate truststores and keystores for broker and clients(consumer/producer)  

```cd private
./create-certs.sh
cd ..
```  
 
build images  
`docker-compose build`  
 
run docker compose file  
`docker-compose up`  
 
if all goes well, the kdc-admin and kafka container should be running, 3 keytabs should be generated in the volume (./private on the host)  
 
you can produce additional log messages by issuing the following command  
`docker-compose exec omkafka_gssapi logger <test message>`  

# TODO

- generate host_krb.conf on the fly instead of static file
- set correct permissions, and do not share keytabs across containers
- ensure correct signing data, hostnames, so that KAFKA_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM works as it should
- ensure all env. variables and hardcoded settings are defined in 1 place