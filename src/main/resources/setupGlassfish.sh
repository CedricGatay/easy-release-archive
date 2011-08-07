#!/bin/bash
if [ `whoami` == root ]; then
    echo "##### Please DO NOT run this script as root or using sudo ! , but as the user running the Glassfish";
    exit;
fi;
RUNNABLEASUSER=true;
source sanityCheck.sh
echo "##### Stop existing domain1, if available"
${GFHOME}/bin/asadmin stop-domain domain1
echo "##### Deleting existing domain1, if available"
${GFHOME}/bin/asadmin delete-domain domain1
echo "##### Creating domain1, please provide admin credentials"
${GFHOME}/bin/asadmin create-domain --instanceport 8081 --domainproperties http.ssl.port=8082 domain1
echo "##### Copying mysql as it is required to ping datasources"
cp -v ../lib/mysql.jar ${GFHOME}domains/${DOMAIN_NAME}/lib/mysql.jar
echo "##### Starting domain1"
${GFHOME}/bin/asadmin start-domain domain1
echo "##### Please login using credentials if needed"
${GFHOME}/bin/asadmin login
PASS=${SQL_PWD};
if [ -z ${SQL_PWD} ]; then
	PASS="''";
fi;
echo "##### Adding a mysql Pool..."
${GFHOME}/bin/asadmin create-jdbc-connection-pool --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource --restype javax.sql.ConnectionPoolDataSource --property "User=${SRM_USER}:Password=${PASS}:URL=jdbc\\:mysql\\://${SQL_HOST}\\:3306/srm" mysqlPool
${GFHOME}/bin/asadmin ping-connection-pool mysqlPool
echo "##### Adding a mysql DataSource..."
${GFHOME}/bin/asadmin create-jdbc-resource --connectionpoolid mysqlPool mysqlDataSource
${GFHOME}/bin/asadmin  list-jdbc-resources

echo "##### Adding mail/MailSession... > localhost sendMail !"
# uncomment and adapt this to create mailSession for use with GMail
#${GFHOME}/bin/asadmin create-javamail-resource --mailhost=smtp.gmail.com --mailuser=bender --fromaddress=me@gmail.com --enabled=true  --storeprotocol=imap --storeprotocolclass=com.sun.mail.imap.IMAPStore --transprotocol smtp --transprotocolclass com.sun.mail.smtp.SMTPSSLTransport --property mail-smtp.user=me@gmail.com:mail-smtp.port=465:mail-smtp.password=mysuperpassword:mail-smtp.auth=true:mail-smtp.socketFactory.fallback=false:mail-smtp.socketFactory.class=javax.net.ssl.SSLSocketFactory:mail-smtp.socketFactory.port=465:mail-smtp.starttls.enable=true mail/MailSession
${GFHOME}/bin/asadmin create-javamail-resource --mailhost=localhost --mailuser=myuser@mydomain.tld --fromaddress=myuser@mydomain.tld --enabled=true --property mail.smtp.port=25:mail.smtp.auth=false:mail.user=myuser@mydomain.tld:mail.from=myuser@mydomain.tld:mail.store.protocol=imap:mail.transport.protocol=smtp:mail.debug=false mail/MailSession
${GFHOME}/bin/asadmin list-javamail-resources

# uncomment the following lines if you want a jk listener
echo "##### Enabling mod_jk..."
${GFHOME}/bin/asadmin create-http-listener --listenerport 8009 --listeneraddress 0.0.0.0 --defaultvs server jk-connector
${GFHOME}/bin/asadmin set configs.config.server-config.network-config.network-listeners.network-listener.jk-connector.jk-enabled=true

echo "##### Resizing max-threads in http-thread-pool"
${GFHOME}/bin/asadmin set server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=200

echo "##### Creating jvm-options"
echo "##### DELETE  \\-XX\\:MaxPermSize=192m"
${GFHOME}/bin/asadmin delete-jvm-options "\\-XX\\:MaxPermSize=192m"
echo "##### DELETE  \\-client"
${GFHOME}/bin/asadmin delete-jvm-options "\\-client"
echo "##### \\-XX\\:MaxPermSize=512m"
${GFHOME}/bin/asadmin create-jvm-options "\\-XX\\:MaxPermSize=512m"
echo "##### \\-server"
${GFHOME}/bin/asadmin create-jvm-options "\\-server"
echo "##### -Dfile.encoding=utf8"
${GFHOME}/bin/asadmin create-jvm-options "-Dfile.encoding=utf8"
# feel free to add another jvm-options if required, you can add multiple option with one command, I prefer doing one at a time in case something goes wrong