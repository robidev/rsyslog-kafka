UNSORTED NOTES:
step-by-step for librdkafka; https://github.com/edenhill/librdkafka/wiki/Using-SASL-with-librdkafka

kerberos setup copied from https://github.com/ist-dsi/docker-kerberos/blob/master/kdc-kadmin/Dockerfile
modified default kerberos5 realm: SYSLOG-TEST.LOCAL

Kafka Authentication with SASL; https://docs.confluent.io/current/kafka/authentication_sasl/index.html
  docker/docker-compose config; https://docs.confluent.io/4.0.0/installation/docker/docs/tutorials/clustered-deployment-sasl.html
  https://github.com/confluentinc/cp-docker-images [cp-docker-images/examples/kafka-cluster-sasl/secrets/]
  keystore/truststore scripts; https://github.com/confluentinc/confluent-platform-security-tools

Install SASL modules on client host
apt-get install libsasl2-modules-gssapi-mit libsasl2-dev

Configure Kafka client on client host
The configuration listed below are standard librdkafka configuration properties (see CONFIGURATION.md), how these are actually set in a librdkafka based client depends on the application, 
for instance kafkacat uses -X <prop>=<val> command line arguments.
  # Use SASL plaintext
  security.protocol=SASL_PLAINTEXT

  # Broker service name
  sasl.kerberos.service.name=$SERVICENAME

  # Client keytab location
  sasl.kerberos.keytab=/etc/security/keytabs/${CLIENT_NAME}.keytab

  # sasl.kerberos.principal
  sasl.kerberos.principal=${CLIENT_NAME}/${CLIENT_HOST}


NOTE: The ${BROKER_HOST} must exactly match the hostname part of the broker's principal. 
E.g., make sure to connect to broker abc123 if the Kerberos principal is kafka/abc123@YOURDOMAMIN.COM.
# kafkacat -b ${BROKER_HOST} -L -X security.protocol=SASL_PLAINTEXT -X sasl.kerberos.keytab=/etc/security/keytabs/${CLIENT_NAME}.keytab -X sasl.kerberos.principal=${CLIENT_NAME}/${CLIENT_HOST}
