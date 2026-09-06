FROM osixia/openldap:1.5.0
LABEL maintainer="GIP RECIA - Julien Gribonvald <julien.gribonvald@recia.fr>"

RUN rm -Rf /container/service/slapd/assets/config/bootstrap/schema/mmc \
    /container/service/slapd/assets/config/bootstrap/schema/postfix-book.schema \
    /container/service/slapd/assets/config/bootstrap/schema/samba.schema

ADD bootstrap /container/service/slapd/assets/config/bootstrap
COPY ldap/check-schema-revision.sh /usr/local/bin/check-schema-revision
#ADD init-db /container/service/slapd/assets/init-db
#ADD certs /container/service/slapd/assets/certs
#ADD environment /container/environment/01-custom

RUN chmod +x /usr/local/bin/check-schema-revision

RUN ls -la /container/service/slapd/assets/config/bootstrap/ldif/*
RUN ls -la /container/service/slapd/assets/config/bootstrap/schema/*
