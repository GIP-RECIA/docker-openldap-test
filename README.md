# docker-openldap-test
an openldap for test


* NOTE: lors d'un changement de schéma il faut supprimer l'image générée puis vider les répertoires des volumes via
```shell
docker ps -a | grep openldap
docker rm ID_IMAGE
docker volume ls -q | grep openldap
docker volume rm xxxx_data
docker volume rm xxxx_config
rm -R $PATH_TO_EACH_VOLUME/*
docker-compose pull && docker-compose build
docker up # -d as optional to be able to read debug logs
```