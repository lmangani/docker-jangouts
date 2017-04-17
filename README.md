## JANUS Gateway Jangouts + Docker
This Docker container provides a fully configured [Janus Gateway](https://github.com/meetecho/janus-gateway) from Meetecho w/ Event API and Demo Server for quick prototyping of Janus plugins.

### Docker Images
Images for this container are available at https://hub.docker.com/r/qxip/docker-janus

#### Docker Run & Mapping
The following command should provide a fully functional container w/ basic mapping
```
docker run -tid --name janus \
-p 7889:7889 -p 7089:7089 -p 8089:8089 -p 7088:7088 \
-p 8088:8088 -p 8000:8000 -p 8080:8080 \
-p 10000-10200/udp:10000-10200/udp \
qxip/docker-janus
```

#### Usage
Before using, you __MUST__ accept the server _self-signed_ certificate:
* browse to server: ```:8080```
* browse to demos: ```:8089```


#### Docker Compose
See ```docker-compose.yml```
