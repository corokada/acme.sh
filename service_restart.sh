#!/bin/sh

#
# 証明書更新後にサービスのリロード
#
# Author: corokada
#

if [ -f /etc/httpd/certs/restart_apache ]; then
    /etc/init.d/httpd graceful
    rm -rf /etc/httpd/certs/restart_apache
fi

if [ -f /etc/httpd/certs/restart_mail ]; then
    /etc/init.d/postfix reload
    /etc/init.d/dovecot reload
    rm -rf /etc/httpd/certs/restart_mail
fi
