#!/bin/sh

#
# apacheにSSL証明書の設定
#
# Author: corokada
#

if [ -z "$1" ]; then
  echo "usage:$0 [domain-name]"
  exit 1
fi

# ドメイン設定
DOMAIN=$1

#証明書保存先
CERTDIR=/etc/httpd/certs

#証明書チェック
if [ ! -f ${CERTDIR}/${DOMAIN}/${DOMAIN}.cer ]; then
    echo "証明書が発行されていません"
    exit 1
fi
if [ ! -f ${CERTDIR}/${DOMAIN}/${DOMAIN}.key ]; then
    echo "証明書が発行されていません"
    exit 1
fi

CONFFILE=`httpd -S | grep "port 80 namevhost ${DOMAIN}" | cut -d'(' -f2 | cut -d':' -f1`

# conf修正(httpd)
sed -i -e "/smtpd_tls_cert_file/c\smtpd_tls_cert_file = ${CERTDIR}/${DOMAIN}/fullchain.cer" ${CONFFILE}
sed -i -e "/SSLCertificateFile/c\    SSLCertificateFile ${CERTDIR}/${DOMAIN}/${DOMAIN}.cer" $CONFFILE
sed -i -e "/SSLCertificateKeyFile/c\    SSLCertificateKeyFile ${CERTDIR}/${DOMAIN}/${DOMAIN}.key" $CONFFILE
sed -i -e "/SSLCACertificateFile/c\    SSLCACertificateFile ${CERTDIR}/${DOMAIN}/ca.cer" $CONFFILE
sed -i -e "s/#SSLVerifyClient/SSLVerifyClient/" ${CONFFILE}
sed -i -e "s/SSLVerifyClient/#SSLVerifyClient/" ${CONFFILE}
sed -i -e "s/#SSLVerifyDepth/SSLVerifyDepth/" ${CONFFILE}
sed -i -e "s/SSLVerifyDepth/#SSLVerifyDepth/" ${CONFFILE}

# サービス再起動
/usr/sbin/apachectl configtest
if [ $? = 0 ]; then
    /etc/init.d/httpd graceful
else
    echo "サービス再起動失敗"
fi
