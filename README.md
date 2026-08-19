# makefile-templates

Des commandes `make` réutilisables d'un projet à l'autre, partagées par un clone
git plutôt que copiées.

Une convention unique :

```
<domaine>@<action>   →   scripts/<domaine>/<action>.sh
```

```
make app@start        make db@migrate        make db@rollback STEP=3
```

Le **vocabulaire** est le même partout ; l'**implémentation** dépend de la stack.
`db@migrate` lance `php artisan migrate` sur un projet Laravel et
`alembic upgrade head` sur un projet FastAPI — la commande tapée, elle, ne change
pas.

Chaque stack est un **dossier autonome** : un fichier `.mk` par domaine, qui ne
fait que déclarer les cibles, et un script par commande, qui porte la logique.
Tout est sur une seule branche, ce qui permet de passer d'une stack à l'autre
sans changer de dépôt.

> **État des scripts.** C'est la structure qui se travaille en premier. Les
> scripts de stack (`app`, `db`) sont des ébauches d'une ligne : ils annoncent
> leur nom et les variables reçues, sans rien exécuter. Seul le domaine `make`,
> qui pilote le dépôt de commandes lui-même, est implémenté.

## Sommaire

- [Prérequis](#prérequis)
- [Installation](#installation)
- [Structure du dépôt](#structure-du-dépôt)
- [Utilisation](#utilisation)
  - [Au quotidien](#au-quotidien)
  - [Les commandes disponibles](#les-commandes-disponibles)
  - [Corriger ou ajouter une commande depuis un projet](#corriger-ou-ajouter-une-commande-depuis-un-projet)
  - [Ajouter une stack](#ajouter-une-stack)
  - [Conventions](#conventions)
- [Licence](#licence)

## Prérequis

| | |
|---|---|
| **git ≥ 2.25** | pour `sparse-checkout` en mode cône, sur lequel repose tout le montage |
| **GNU make** | celui de toute distribution Linux, et de macOS via `brew install make` |
| **bash** | les scripts sont en `#!/usr/bin/env bash`, pas en `sh` |

## Installation

### 1. Brancher le dépôt

Le dépôt se branche en `.make/` à la racine du projet. Des stacks, seule celle du
projet est matérialisée sur le disque, avec les fichiers de la racine :

```bash
cd ~/projets/mon-api-laravel
git clone --depth 1 --filter=blob:none --sparse \
  git@github.com:<toi>/makefile-templates.git .make
git -C .make sparse-checkout set laravel core
echo '/.make/' >> .gitignore
```

`core` accompagne la stack dans le cône : c'est le seul dossier à ne jamais
retirer, et le seul endroit où il faut y penser — `make@stack` le réinjecte
ensuite tout seul.

`.make/` reste un dépôt git complet : `git pull` met à jour les commandes, et
changer de stack ne demande pas de re-cloner.

### 2. Poser le Makefile du projet

```bash
cp .make/Makefile.example Makefile
```

Un seul modèle pour toutes les stacks, et rien à y renseigner : il importe tous
les fragments présents dans `.make/`, quels qu'ils soient.

```make
include $(wildcard .make/*/*.mk)
```

Le `Makefile` ignore donc jusqu'à la notion de stack — il ne fait qu'inclure ce
qu'il trouve. C'est `sparse-checkout` qui décide de ce qui est sur le disque, et
le `wildcard` suit sans rien demander : rien à modifier quand un domaine est
ajouté au dépôt, rien non plus quand le projet change de stack.

Le nom affiché en tête de liste est celui du dossier du projet, et il n'est pas
paramétrable : rien à faire, donc, ni à pouvoir faire.

### 3. Vérifier

```bash
make
```

La liste des commandes s'affiche, précédée du nom du projet.

## Structure du dépôt

```
makefile-templates/
├── Makefile.example              le même quelle que soit la stack
├── CHANGELOG.md                  alimenté par make@push
├── LICENSE
├── core/                         sans stack, toujours matérialisé
│   ├── make.mk                   make@update make@stack make@push …
│   └── scripts/make/
│       ├── {update,stack,stack-add,status,push}.sh
│       └── lib.sh                sourcé par les cinq
├── laravel/
│   ├── app.mk                    app@install app@start app@stop
│   ├── db.mk                     db@migrate db@rollback
│   └── scripts/
│       ├── app/{install,start,stop}.sh
│       └── db/{migrate,rollback}.sh
└── fastapi/
    └── …
```

`core/` est un dossier de fragments comme un autre pour le `Makefile`, qui ne
distingue pas les stacks. Ce qui l'en sépare tient en une phrase : ses commandes
agissent sur le clone `.make/` lui-même, pas sur le projet — il n'a donc pas à
disparaître quand on change de stack.

## Utilisation

### Au quotidien

Le domaine `make` porte les gestes sur le clone, pour ne pas avoir à retenir les
`git -C` ni à penser à `core` :

```bash
make make@update                   # mettre à jour les commandes
make make@stack STACK=fastapi      # changer de stack
make make@stack-add STACK=fastapi  # en matérialiser une seconde
make make@status                   # ce que le clone a de modifié
```

Chacune affiche le `git` qu'elle lance, recopiable tel quel si le besoin est de
le faire à la main :

```bash
git -C .make pull --rebase
git -C .make sparse-checkout set fastapi core
git -C .make sparse-checkout add fastapi
```

`make@stack` et `make@stack-add` refusent une stack absente du dépôt plutôt que
de vider le cône sur une coquille, et listent celles qui existent — matérialisées
ou non :

```
$ make make@stack STACK=symfny
make@stack : stack « symfny » inconnue du dépôt (disponibles : fastapi laravel)
```

**Changer de stack** : `make@stack STACK=fastapi`, et rien d'autre. Le `Makefile`
suit.

**Une seule stack à la fois**, en revanche. Le `Makefile` incluant tout ce qu'il
trouve, deux stacks matérialisées côte à côte définissent les mêmes cibles deux
fois : `make` prévient (`surchargement de la recette pour la cible « app@start »`)
et garde la dernière incluse, par ordre alphabétique. Utile le temps de comparer
deux stacks, à ne pas laisser en place pour travailler.

### Les commandes disponibles

`make` sans argument liste ce qui est disponible : les commandes de la stack
matérialisée, et celles de `core/`.

Les domaines `app` et `db`, dont l'implémentation dépend de la stack :

| Cible | Laravel | FastAPI |
|---|---|---|
| `app@install` | `.env`, conteneurs, `composer install`, `key:generate`, migrations, assets | `.env`, conteneurs, `pip install -e ".[dev]"`, migrations |
| `app@start` | `docker compose up -d` | `docker compose up -d` |
| `app@stop` | `docker compose down` | `docker compose down` |
| `db@migrate` | `artisan migrate --force` | `alembic upgrade $(REVISION)` |
| `db@rollback` | `artisan migrate:rollback --step=$(STEP)` | `alembic downgrade -$(STEP)` |

Le domaine `make` de `core/`, qui ne dépend d'aucune stack — et le seul à être
**implémenté** : ces commandes agissent pour de bon.

| Cible | |
|---|---|
| `make@update` | `git -C .make pull --rebase` |
| `make@stack` | `sparse-checkout set $(STACK) core` |
| `make@stack-add` | `sparse-checkout add $(STACK)` |
| `make@status` | `git -C .make status --short --branch` |
| `make@push` | entrée de changelog + `add` + `commit -m "$(M)"` + `push` |

Les scripts de stack, eux, sont des ébauches : chacun se réduit à un `echo` qui
annonce son nom et les variables reçues. Le premier tableau décrit donc ce qu'ils
feront, pas ce qu'ils font.

```bash
#!/usr/bin/env bash
# db@rollback — annule les derniers batchs de migrations (STEP)
#
# Ébauche : la commande annonce seulement son nom et les variables qu’elle reçoit.
set -euo pipefail

echo "db@rollback  EXEC=${EXEC:-}  STEP=${STEP:-}"
```

```
$ make db@rollback STEP=3
db@rollback  EXEC=docker compose exec -T app  STEP=3
```

La structure s'éprouve entièrement de cette façon, sans Docker ni projet réel :
le chaînage `make` → fragment → script, le passage des variables, le listing, la
bascule de stack.

La différence de traitement suit la frontière du dépôt. Le domaine `make` pilote
le clone `.make/`, qui existe ici et maintenant — il n'a rien à attendre. Les
domaines `app` et `db` visent un projet et une stack qui, dans ce dépôt, ne sont
que des exemples : les écrire demanderait de choisir un vrai projet, ce qui n'est
pas le sujet.

### Corriger ou ajouter une commande depuis un projet

C'est le geste central du dépôt, et il ne demande aucune mise en place : `.make/`
étant un clone et non une copie, **le fichier édité est celui qui s'exécute**.
Une commande se met donc au point dans les conditions réelles d'un projet, et ne
remonte qu'une fois qu'elle marche.

```bash
# 1. corriger ou ajouter, dans la stack du projet
vim .make/laravel/db.mk
vim .make/laravel/scripts/db/seed.sh  &&  chmod +x $_

# 2. tester tout de suite — rien à réinstaller, le Makefile inclut ces fichiers
make db@seed

# 3. renvoyer au dépôt de templates
make make@push M="db@seed sur la stack laravel"
```

La cible apparaît dans la liste dès l'étape 2, du seul fait d'être déclarée en
`.PHONY`.

`make@status` montre ce que le clone a de modifié, et `make@push` fait l'ajout,
le commit et le push d'un coup — le message est le seul élément à fournir. Si un
collègue est passé avant, le push est refusé : `make make@update`, puis
`make make@push` à nouveau.

**Le changelog s'écrit au passage.** Le message sert deux fois : message de
commit, et entrée dans `CHANGELOG.md`, ajoutée en tête de la section
« Non publié » et datée du jour.

```
$ make make@push M="db@seed sur la stack laravel"
  CHANGELOG.md ← - 2026-08-19  db@seed sur la stack laravel
  git -C .make add -A
  git -C .make commit -m "db@seed sur la stack laravel"
  git -C .make push
```

Le fichier est à la racine du dépôt, donc toujours dans le cône : il est là
quelle que soit la stack matérialisée, et se corrige à la main comme n'importe
quel autre fichier du clone. Pour ce qui ne mérite pas d'y figurer :

```bash
make make@push M="coquille dans un commentaire" CHANGELOG=no
```

Un `CHANGELOG.md` absent, ou sans section `## Non publié`, ne fait pas échouer le
push : la commande le signale et continue.

**Générique ou local ?** C'est la seule décision à prendre, et elle se prend
avant d'éditer. Ce qui vaut pour tous les projets de la stack va dans
`.make/laravel/` et se pousse ; ce qui n'est vrai que de ce projet-ci va dans son
`local.mk`, qui ne concerne pas les templates.

**Commiter avant de changer de stack.** C'est le seul piège du montage. Un
`make@stack STACK=fastapi` alors qu'une modification traîne dans `laravel/` ne
perd rien — git refuse de retirer le fichier et le signale — mais laisse les deux
stacks sur le disque, donc `make` avertit sur les cibles en double, et le fichier,
désormais hors du cône, n'est plus pris ni par `git add` ni par `commit -a`. On
s'en sort en revenant sur la stack, `make@stack STACK=laravel`, pour commiter
puis basculer.

Les trois particularités du clone ne gênent aucune de ces étapes :

| | |
|---|---|
| `--depth 1` | le push depuis un clone superficiel passe. Si un serveur le refuse (`shallow update not allowed`), `git -C .make fetch --unshallow` une fois pour toutes |
| `--filter=blob:none` | `git status` voit les modifications et les fichiers nouveaux |
| `sparse-checkout` | les stacks non matérialisées ne sont pas sur le disque, mais commit, rebase et push ne les effacent pas du dépôt |

### Ajouter une stack

1. Copier un dossier de stack existant : `cp -R laravel/ symfony/`. Rien à faire
   côté `Makefile.example`, commun à toutes les stacks, ni côté `core/`, qui
   n'est pas une stack et sert déjà la nouvelle.
2. Adapter `EXEC` dans les `.mk`, puis les commandes dans `scripts/app/` et
   `scripts/db/`.
3. Garder les mêmes noms de cibles dès que l'action a le même sens : c'est tout
   l'intérêt de la convention.

### Conventions

**Nommage.** `domaine@action`, en minuscules, tirets pour les mots composés
(`db@make-migration`). Un fichier `.mk` par domaine, un script par action :
`make db@migrate` exécute `scripts/db/migrate.sh`.

**Séparation.** Le `.mk` ne déclare que l'interface et délègue immédiatement ;
toute la logique vit dans le script, en bash lisible et debuggable seul. Un
domaine qui a de quoi se répéter pose un `lib.sh` à côté de ses actions, sourcé
par chacune — c'est ce que fait `core/scripts/make/`.

```make
db@migrate:
	@$(DB_SCRIPTS)/db/migrate.sh
```

La variable porte le nom de son domaine — `APP_SCRIPTS`, `DB_SCRIPTS`,
`MAKE_SCRIPTS` — et pas simplement `SCRIPTS` : les fragments sont inclus dans le
même `Makefile`, où un `:=` commun serait écrasé par le dernier inclus, et les
recettes, expansées plus tard, iraient toutes chercher leurs scripts au même
endroit.

**Listing.** La liste affichée par `make` est lue dans les `.PHONY` : une cible y
apparaît du seul fait d'être déclarée.

```make
.PHONY: db@migrate db@rollback
```

**Paramètres.** Passés en variables, jamais en arguments positionnels :
`make db@rollback STEP=3`. Le fragment déclare la valeur par défaut avec `?=` et
l'exporte ; le script la lit dans son environnement (`"$STEP"`). Les scripts sont
donc faits pour être lancés par make, pas à la main. Les paramètres existants
sont `STEP` (les deux stacks, défaut `1`), `REVISION` (FastAPI, défaut `head`),
`STACK`, `M` et `CHANGELOG` (domaine `make`, défaut `yes`).

**Exécution.** Chaque fragment définit `EXEC ?= docker compose exec -T <service>`
et l'exporte ; les scripts préfixeront leurs commandes avec (`$EXEC php artisan
migrate --force`) — pour l'instant ils se contentent de l'afficher. Sortir de
Docker ne demandera donc de toucher à aucun script : il suffit de redéfinir
`EXEC` dans le `local.mk` du projet, ou dans son `Makefile` sous l'`include`.

```make
EXEC :=                       # directement sur la machine
EXEC := ./vendor/bin/sail     # via Sail
```

L'endroit compte : ces deux emplacements sont lus après les fragments, donc la
valeur du projet l'emporte. Le `export` posé par le fragment, lui, reste acquis —
les scripts voient la valeur redéfinie. Le domaine `make` fait exception : ses
commandes agissent sur le clone, pas dans un conteneur, et ne passent donc pas
par `EXEC`.

**Configuration.** Il n'y en a pas : le modèle se copie tel quel, et ne contient
aucune valeur propre au projet — pas même le nom de la stack, qu'il n'a pas à
connaître. Le contenu de `.make/` est la seule source de vérité, donc rien ne
peut diverger du disque ; le nom du projet est celui de son dossier. Un `.make/`
vide ne fait rien échouer : `make` liste zéro commande, ce qui se lit tout seul.

**Surcharges projet.** Tout ce qui est propre à un projet — une cible, ou une
valeur comme `EXEC`, ou `.DEFAULT_GOAL` pour que `make` nu fasse autre chose que
lister — se met sous l'`include`, dans son `Makefile` ou dans un `local.mk` à la
racine, inclus s'il existe. Les cibles déclarées en `.PHONY` apparaissent dans la
liste comme les autres. Le `local.mk` appartient au projet : à lui de décider
s'il le versionne (surcharges d'équipe) ou l'ignore (surcharges personnelles).

Rien de tout cela ne se dépose dans `.make/` : ce qui y est édité s'adresse à
tous les projets de la stack et doit être poussé, sans quoi un nouveau clone
l'emporte. La frontière est donc celle de la section précédente — une correction
générique dans `.make/`, aussitôt poussée ; une particularité du projet dans son
`local.mk`.

## Licence

[MIT](LICENSE) — usage libre, y compris commercial, sans aucune garantie.
