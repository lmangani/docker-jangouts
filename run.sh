#!/bin/bash

# Patch Config to enable Event Handler
CFG_EVENT='/root/janus/etc/janus/janus.eventhandler.sampleevh.cfg'
# sed 's/enabled = no/enabled = yes/1' -i $CFG_EVENT
# echo 'backend = http://localhost:7777' >> $CFG_EVENT
CFG_JANUS='/root/janus/etc/janus/janus.cfg'
sed 's/; broadcast = yes/broadcast = yes/1' -i $CFG_JANUS
CFG_HTTPS='/root/janus/etc/janus/janus.transport.http.cfg'
sed 's/https = no/https = yes/1' -i $CFG_HTTPS
sed 's/;secure_port = 8889/secure_port = 8889/1' -i $CFG_HTTPS

CFG_JANGOUTS='/root/jangouts/config.json'
if [ -n "$DOMAIN_NAME" ]; then
    if [ -n "$PUBLIC_PORT" ]; then
        sed 's|\"janusServerSSL\": null,|\"janusServerSSL\": \"https:\/\/$DOMAIN_NAME:$PUBLIC_PORT/janus\",|' -i $CFG_JANGOUTS
    else
        sed 's|\"janusServerSSL\": null,|\"janusServerSSL\": \"https:\/\/$DOMAIN_NAME/janus\",|' -i $CFG_JANGOUTS
    fi
fi

if [ -d "/etc/letsencrypt/production/certs" ]; then
    cp /etc/letsencrypt/production/certs/*/fullchain.pem /root/janus/share/janus/certs/mycert.pem
    cp /etc/letsencrypt/production/certs/*/privkey.pem /root/janus/share/janus/certs/mycert.key
    # Start demo server
    npm install http-server -g
    ln -s /usr/bin/nodejs /usr/bin/node
    http-server /root/jangouts/ --key /root/janus/share/janus/certs/mycert.key \
      --cert /root/janus/share/janus/certs/mycert.pem -d false -p 8080 -c-1 --ssl &
else 
    # Generate Certs
    openssl req -x509 -newkey rsa:4086 \
      -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
      -keyout "/usr/share/key.pem" \
      -out "/usr/share/cert.pem" \
      -days 3650 -nodes -sha256

    cp /usr/share/cert.pem /root/janus/share/janus/certs/mycert.pem
    cp /usr/share/key.pem /root/janus/share/janus/certs/mycert.key
    # Start demo server
    npm install http-server -g
    ln -s /usr/bin/nodejs /usr/bin/node
    http-server /root/jangouts/ --key /usr/share/key.pem \
      --cert /usr/share/cert.pem -d false -p 8080 -c-1 --ssl &
fi

# Start Evapi Demo
# npm install http -g
# nodejs /evapi.js >> /var/log/meetecho &

# Start Janus Gateway in forever mode
CMD="/root/janus/bin/janus --stun-server=stun.l.google.com:19302 -L /var/log/meetecho --rtp-port-range=10000-10200"
until $CMD
do
    :
done

tail -f /var/log/meetecho

