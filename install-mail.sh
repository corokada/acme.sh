#!/bin/sh

#
# postfix/dovecotにSSL証明書の設定
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
if [ ! -f ${CERTDIR}/${DOMAIN}/fullchain.cer ]; then
    echo "証明書が発行されていません"
    exit 1
fi
if [ ! -f ${CERTDIR}/${DOMAIN}/${DOMAIN}.key ]; then
    echo "証明書が発行されていません"
    exit 1
fi

# conf修正(postfix)
sed -i -e "/smtpd_tls_cert_file/c\smtpd_tls_cert_file = ${CERTDIR}/${DOMAIN}/fullchain.cer" /etc/postfix/main.cf
sed -i -e "/smtpd_tls_key_file/c\smtpd_tls_key_file = ${CERTDIR}/${DOMAIN}/${DOMAIN}.key" /etc/postfix/main.cf

# conf修正(dovecot)
sed -i -e "/ssl_cert /c\ssl_cert = <${CERTDIR}/${DOMAIN}/fullchain.cer" /etc/dovecot/conf.d/10-ssl.conf
sed -i -e "/ssl_key /c\ssl_key = <${CERTDIR}/${DOMAIN}/${DOMAIN}.key" /etc/dovecot/conf.d/10-ssl.conf

# サービス再起動
/etc/init.d/postfix reload
/etc/init.d/dovecot reload
