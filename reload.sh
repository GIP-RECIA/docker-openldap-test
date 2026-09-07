#!/bin/bash
docker rm ldapsarapis
docker volume rm docker-openldap-sarapis_sarapis-ldap-config
docker volume rm docker-openldap-sarapis_sarapis-ldap-data
docker compose build --no-cache openldap
docker compose up