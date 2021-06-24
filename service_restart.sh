#!/bin/sh

#
# 証明書更新後にサービスのリロード
#
# Author: corokada
#

if [ -f /etc/httpd/certs/restart_apache ]; then
    if [ -f /etc/init.d/httpd ]; then
        /etc/init.d/httpd graceful
    else
        /bin/systemctl reload httpd
    fi
    rm -rf /etc/httpd/certs/restart_apache
fi

if [ -f /etc/httpd/certs/restart_mail ]; then
    if [ -f /etc/init.d/postfix ]; then
        /etc/init.d/postfix reload
        /etc/init.d/dovecot reload
    else
        /bin/systemctl reload postfix
        /bin/systemctl reload dovecot
    fi
    rm -rf /etc/httpd/certs/restart_mail
fi
