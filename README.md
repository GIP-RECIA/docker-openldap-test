# OpenLDAP test

Annuaire OpenLDAP de test initialise avec le schema et les donnees de bootstrap.

Le demarrage standard est autonome et ne requiert pas le referentiel de schema :

```sh
docker compose up -d
```

Le service optionnel `schema-status` compare les fichiers de schema embarques dans l'image avec le referentiel local `esco-referentiel-schema-ldap`. Il est active uniquement par les scripts de gestion locaux.

En cas de difference, `schema-status` se termine avec le code `42` et affiche `SCHEMA_UPDATE_CHECK_REQUIRED`. Executer alors `./scripts/check-schema-update.sh`, qui recupere la reference Git et indique ensuite si `./scripts/update-schema.sh` doit etre lance.

## Commandes recommandees

Pour un developpement local disposant du referentiel de schema, utiliser les scripts avant les commandes Docker brutes :

```sh
./scripts/up.sh
./scripts/down.sh
```

`up.sh` affiche le statut de synchronisation du schema. `down.sh` arrete l'annuaire sans supprimer les volumes.

Pour verifier ou mettre a jour le schema, suivre cette sequence :

```sh
./scripts/check-schema-update.sh
./scripts/update-schema.sh
```

`update-schema.sh` supprime les volumes LDAP de test apres confirmation.

## Mode CI ou manuel sans referentiel

Demarrer l'annuaire sans controle du referentiel de schema :

```sh
docker compose up -d
docker compose ps
docker compose logs -f openldap
```

Arreter l'annuaire en conservant les volumes :

```sh
docker compose down
```

Arreter l'annuaire et supprimer les donnees de test :

```sh
docker compose down -v
```

## Gestion locale du schema

Avant un lancement Compose non interactif, definir `SCHEMA_REFERENCE_DIR` dans l'environnement ou copier `.env.example` vers `.env` et renseigner le chemin du referentiel.

Pour demarrer OpenLDAP en mode detache tout en affichant le resultat du controle de schema a la fin, utiliser :

```sh
./scripts/up.sh
```

Cette commande retourne `42` si une mise a jour de schema est disponible.

Pour arreter l'annuaire en conservant les volumes LDAP :

```sh
./scripts/down.sh
```

Les projets consommateurs peuvent donc cloner ce depot et lancer directement `docker compose up` en CI. Les scripts locaux ajoutent uniquement le controle de synchronisation avec le referentiel de schema.

Pour recuperer explicitement la derniere reference distante et afficher le diff avant toute mise a jour :

```sh
./scripts/check-schema-update.sh
```

La branche de reference est `origin/master` par defaut. Elle peut etre surchargee avec `SCHEMA_REFERENCE_REF`. Le chemin du referentiel peut etre surcharge avec `SCHEMA_REFERENCE_DIR`.

## Mise a jour du schema

La mise a jour est explicite. Elle recupere la reference Git, copie le meme commit dans le bootstrap Docker, puis recree les volumes Docker de l'annuaire de test : les donnees et la configuration LDAP sont donc supprimees puis rechargees depuis le bootstrap.

```sh
./scripts/update-schema.sh
```

Pour une execution non interactive :

```sh
./scripts/update-schema.sh --yes
```

Le schema n'est jamais mis a jour automatiquement lors d'un `docker compose up`.
