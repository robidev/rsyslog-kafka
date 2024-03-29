#!/bin/bash
echo "==================================================================================="
echo "==== Kerberos Client =============================================================="
echo "==================================================================================="
KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM

echo "REALM: $REALM"
echo "KADMIN_PRINCIPAL_FULL: $KADMIN_PRINCIPAL_FULL"
echo "KADMIN_PASSWORD: $KADMIN_PASSWORD"
echo ""

function kadminCommand {
    kadmin -p $KADMIN_PRINCIPAL_FULL -w $KADMIN_PASSWORD -q "$1"
}

echo "==================================================================================="
echo "==== /etc/krb5.conf ==============================================================="
echo "==================================================================================="
tee /etc/krb5.conf <<EOF
[libdefaults]
	default_realm = $REALM

[realms]
	$REALM = {
		kdc = kdc-kadmin
		admin_server = kdc-kadmin
	}
EOF
echo ""

echo "==================================================================================="
echo "==== Testing ======================================================================"
echo "==================================================================================="
until kadminCommand "list_principals $KADMIN_PRINCIPAL_FULL"; do
  >&2 echo "KDC is unavailable - sleeping 1 sec"
  sleep 1
done
echo "KDC and Kadmin are operational"


echo "==================================================================================="
echo "==== Create kafka keytab =========================================================="
echo "==================================================================================="
echo "Remove old keytab"
rm /etc/kafka/secrets/kafka.keytab
echo "Adding keytab"
kadminCommand "addprinc -randkey kafka/kafka@$REALM"
echo ""
kadminCommand "ktadd -k /etc/kafka/secrets/kafka.keytab kafka/kafka@$REALM"
echo ""
chmod 0777 /etc/kafka/secrets/kafka.keytab
echo ""

echo "==================================================================================="
echo "==== Create client keytab ========================================================="
echo "==================================================================================="
echo "Adding keytab"
for principal in saslproducer saslconsumer
do
  rm /etc/kafka/secrets/${principal}.keytab
  kadminCommand "addprinc -randkey ${principal}/kafka@$REALM"
  kadminCommand "ktadd -norandkey -k /etc/kafka/secrets/${principal}.keytab ${principal}/kafka@$REALM"
  chmod 0777 /etc/kafka/secrets/${principal}.keytab
done

echo "done"
sleep 10