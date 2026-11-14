# Runner Go : validation et réutilisation des exécutables

`bin/run` et `bin/test` passent par `bin/_go-run` pour les exécutables Go non
bundlés. Le runner appelle **toujours `go build`** avant d'exécuter l'application.
Les sources, dépendances, options et le toolchain sont validés par Go.

## Cache et publication

Le cache partagé entre les conteneurs API est `var/api/cache/go/` :

- `build/` et `modules/` : caches Go, remplaçables par `GOCACHE` et `GOMODCACHE` ;
- `bin/<cible>-<clé>-<sha256>` : exécutables publiés par contenu ;
- `latest/<cible>-<clé>` : empreinte du dernier exécutable construit avec succès ;
- `build.lock` : verrou noyau commun à la validation et à la publication.

La cible provient de `go env GOOS GOARCH`. La clé identifie le répertoire Go et
le chemin du point d'entrée. `latest` est un **indice de réutilisation**, pas une
preuve que les sources sont à jour : il contient uniquement un SHA-256 hexadécimal.

Sous le verrou, le runner copie le dernier exécutable dans un fichier temporaire
privé et vérifie son empreinte. Il présente cette copie à `go build -o`. Go peut
ainsi reconnaître un exécutable à jour par son build ID et éviter le lien. Une
cible temporaire vide imposait auparavant un nouveau lien, même avec les packages
en cache. La copie n'est jamais un lien physique vers l'exécutable publié.

Un indice absent/invalide ou un artefact absent laisse une cible vide ; un contenu
altéré est détecté avant la validation Go et déclenche la reconstruction. Après
succès, le runner déduplique les contenus identiques et publie le nouvel indice
par renommage atomique. Une publication endommagée peut être réparée par renommage,
sans réécrire son inode.

Chaque invocation conserve le chemin de **son propre résultat**. Elle libère le
verrou avant `exec` ; les applications peuvent donc tourner simultanément. Un
échec ou une annulation de build ne lance jamais l'ancien exécutable et conserve
l'indice précédemment publié. L'annulation termine le groupe de processus du
build concerné. Le runtime reçoit les arguments, l'environnement et l'umask de
l'appelant, ainsi que ses signaux après `exec`.

## Diagnostics et ressources

Le message d'attente apparaît seulement si l'essai non bloquant rencontre un
verrou occupé. Le runner affiche ensuite la durée d'acquisition et la durée de
l'appel `go build`, y compris son statut en cas d'échec. Sous Linux, ces durées
utilisent l'horloge monotone `/proc/uptime`, de résolution 10 ms ; elles ne couvrent
pas toutes les copies et publications de fichiers. Les mesures de bout en bout
doivent donc chronométrer l'invocation entière. Le diagnostic « Go preparation
finished » couvre l'attente du verrou, les copies/empreintes, le build et la
publication. Il exclut le lancement Docker et l'exécution de l'application ;
« Running Go application » marque toujours la frontière juste avant `exec`.

Les limites du build sont distinctes et configurables :

| Variable | Défaut | Effet |
| --- | --- | --- |
| `B8X_GO_BUILD_PROCS` | `4` | `GOMAXPROCS` des processus du build |
| `B8X_GO_BUILD_PARALLELISM` | `8` | `go build -p`, parallélisme entre packages |
| `B8X_GO_BUILD_MEMORY` | `12GiB` | cible GC souple `GOMEMLIMIT` par processus |

`GOWORK=off` est réservé au build. Ces réglages ne sont pas exportés vers
l'application. La compilation continue d'utiliser `-mod=mod`.

### Réglage du 24 octobre 2026

Le défaut passe de deux à quatre threads de build, le parallélisme entre
packages reste alors à un, et la cible mémoire à 12 GiB. Le conteneur mesuré
utilise Go 1.26.8 Linux ARM64, voit 14 CPU et environ 23,5 GiB de mémoire. Le
compilateur Go y sélectionne respectivement `-c=2` et `-c=4` pour ces deux
réglages.

Le plus gros package généré actuel contient 41,5 Mo de source. Sa compilation
est forcée directement avec la commande du vrai `go build`, les mêmes sources
et les mêmes archives de dépendances. Chaque essai écrit une archive temporaire
neuve ; ni cache de compilation vidé, ni suite métier exécutée. L'ordre est
2 / 4 / 6 / 4 / 2 threads :

| Threads | Compilation du package, secondes | Médiane | Pic RSS maximal |
| --- | --- | --- | --- |
| 2 | 43,763 ; 40,486 | 42,125 s | 8,6 GiB |
| 4 | 29,375 ; 29,137 | 29,256 s | 8,1 GiB |
| 6 | 28,453 (exploratoire) | — | 7,3 GiB |

Le gain médian est de **30,5 % sur ce package**. Les cinq archives de 400 Mo ont
le même SHA-256. Six threads n'apportent qu'un petit écart sur cet essai unique ;
quatre est le réglage retenu. Ce protocole ne mesure pas un premier `t` complet
avec tous les caches vides et ne fixe pas une borne de latence à froid.

Sur trois paires de relances de `Test.Main`, arrêtées juste avant `exec`, la
médiane est de 0,736 s à deux threads et 0,709 s à quatre. Un contrôle du défaut
sans override donne 0,748 s, dont 0,140 s dans `go build`. Aucune compilation ni
édition de liens dans ces sept traces. La référence historique du runner était
de 0,745 s à chaud (voir plus bas), sur un état antérieur du projet.
Les dix contrôles du runner, dont le contrôle natif Go, passent dans ce même
conteneur après le changement (aucun contrôle ignoré).

La [baseline officielle altbak.pub](../../altbak.pub/README.md) de 33,037 s pour
b8x concerne le compilateur gopurs vers Go ; elle n'est pas directement
comparable à cette mesure du compilateur Go ni au runner jusqu'à `exec`.
Les scripts, traces et résultats sont conservés dans
`../.gopurs-evidence/go-run-startup-20261024/` depuis la racine b8x.

### Réglage du 26 octobre 2026

Le défaut de `B8X_GO_BUILD_PARALLELISM` passe de **1 à 8**. Mesure dans le
conteneur `core-api-cli-1` (Go 1.26.8 linux/arm64, 14 CPU, ~23 GiB), avec un
`GOCACHE` neuf pour chaque essai et la sortie b8x réelle :

| `-p` | Build complet froid | Médiane | Pic mémoire du conteneur |
| ---: | ---: | ---: | ---: |
| 1 | 88,558 ; 84,949 s | 86,754 s | 12,2–12,6 GiB |
| 2 | 80,899 s | 80,899 s | 12,4 GiB |
| 4 | 78,715 ; 80,184 s | 79,450 s | 12,5–13,1 GiB |
| 8 | 75,732 ; 76,475 s | **76,104 s** | 12,6–13,0 GiB |

`-p 8` retenu : **−10,65 s (−12,3 %) face à `-p 1`** et **−3,35 s (−4,2 %)**
face à `-p 4`, avec un pic mémoire du même ordre. `-p 4` reste le défaut de
secours pour une machine ou un CI moins doté (`B8X_GO_BUILD_PARALLELISM=4`).
Le gros package de 72,7 Mo reste le chemin critique ; `-p` ne le découpe pas.
Sur cache chaud, `-p` reste sans effet mesurable.

Preuves : [`../../.gopurs-evidence/go-parallel-20261026/RESULTS.md`](../../.gopurs-evidence/go-parallel-20261026/RESULTS.md).

### Silence après le lancement de l'application

Des sondes isolées du même code généré mesurent 1,6 à 6,4 ms pour lancer un
exécutable important les packages de `Test.Main` et résoudre son getter, sans
exécuter son effet. Une deuxième sonde assemble les mêmes specs Core/Infra/Util
et appelle uniquement `Test.Spec.collect` : 45 racines collectées en 4,2 à
6,1 ms. Aucun corps de test ni création de base n'est exécuté dans ces sondes.
Les scripts et résultats figurent dans les sous-dossiers `initialization` et
`collection` des preuves Linux. `collection-attempt1` conserve un échec propre
à l'adaptateur de mesure : la continuation utilisait `pure Effect` au lieu de
`pure Aff`, corrigé avant les trois mesures réussies.

Les reporters actuels n'affichent rien à l'entrée de la suite ou d'un test ;
le premier résultat attend la fin de l'intégration « should execute a single
command », y compris la préparation et le nettoyage PostgreSQL. Une attente
après « Running Go application » peut donc appartenir à ce travail. Sa durée
n'a pas été mesurée par ces sondes ; elles ne valident pas la suite métier.

## Vérifications reproductibles

Depuis la racine de b8x :

```sh
node --test test/go-run.mjs
```

Les neuf contrôles de contrats utilisent un faux Go instrumenté : environnement,
arguments/statut, copie privée, publication immuable, erreurs, sérialisation des
builds, applications concurrentes et annulations. Sur macOS, des shims Python
fournissent les primitives noyau de `flock`/`setsid` pour ces tests.

Pour exercer également le vrai Go :

```sh
docker exec \
  -e PATH=/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin \
  -e B8X_GO_RUN_NATIVE_TEST=1 \
  core-api-cli-1 node --test /var/www/b8x/test/go-run.mjs
```

Le dixième contrôle inspecte les traces `go build -x` : aucun compilateur ni
éditeur de liens sur une relance identique ; prise en compte du point d'entrée,
d'une dépendance modifiée à date conservée, du `go.mod` et des `-ldflags` ; échec
de compilation sans exécution ; reprise ; indice absent/invalide ; exécutable
absent ou altéré tout en conservant son build ID.

Le contrôle natif couvre aussi le passage à des packages générés imbriqués,
l'édition d'une dépendance transitive avec conservation d'un package indépendant,
deux chemins d'entrée distincts, puis le retour au layout antérieur. Il vérifie
les actions `compile`/`link`, l'inode du verrou et les indices d'exécutables.
`B8X_GO_RUN_TEST_EVIDENCE=/répertoire/existant` conserve les racines isolées et les
traces stdout/stderr de chaque invocation.

`B8X_GO_RUN_TEST_HELPER=/chemin/vers/_go-run` permet de rejouer le reproducteur
contre une autre version du runner. L'ancien runner échoue au contrôle de la
relance identique : sa trace contient encore un appel à l'éditeur de liens.

### Utiliser le layout gopurs G06

Depuis la racine b8x, avec la cible Go et la toolchain TAST habituelles :

```sh
export GOPURS_GO_PACKAGES=1
bin/build
bin/test
```

Conserver cette variable pour les builds suivants, y compris `bin/test -b`.
`bin/_gopurs` appelle le compilateur du checkout voisin
`../gopurs/gopurs/bin/gopurs`. La densité retenue est **1/8192** ; les artefacts
JS, Go natif et Rust et le WASM sont identifiés dans le
[bilan G06](../../gopurs/gopurs/docs/build-go-measurements.md).

Le changement de compilateur/layout invalide le cache gopurs au premier build.
Le journal migre les anciennes sorties possédées dans la même racine, sans
supprimer les fichiers externes ni remplacer l'inode du verrou. Pour revenir au
monolithe : `GOPURS_GO_PACKAGES=0 bin/build`. Pour forcer la génération complète
du layout choisi : `GOPURS_GO_PACKAGES=1 GOPURS_FORCE_BUILD=1 bin/build`.
La [procédure de récupération](../../gopurs/gopurs/docs/build-cache.md#réinitialiser-le-cache-réutilisable-du-projet)
conserve le journal et le verrou.

Les points d'entrée restent les mêmes. Lors de la campagne G06, le runner laissait
Go valider les imports transitifs avec **GOMAXPROCS=2 / -p 1 / GOMEMLIMIT=12GiB**. Sur trois paires
alternées par scénario b8x, la chaîne jusqu'à `exec` passe de **268,816 à 99,772 s
sur la feuille**, de **289,840 à 149,661 s sur le partagé**, et de **265,350 à
120,738 s sur la FFI**. Le backend seul ralentit respectivement de **26,88 % /
34,37 % / 42,62 %** face à `publicsync` ; le froid backend reste autour de
**118 s**, loin des ~30 s évoquées au départ. Ces temps s'arrêtent avant la suite
métier/PostgreSQL. La préparation incrémentale P reste en pause après G.

**Validation finale du 16 octobre :** les dix contrôles du runner passent sur
macOS/Go 1.27.0 et Linux ARM64/Go 1.26.8, avec les artefacts G06 installés et
audités. Les preuves sont dans
`gopurs-go-packages-g06-20261014/delivery-7/replays-3/`. G est clos à **7/7** ;
la pause avant P00 est effective.

## Validation et mesures — 9–10 octobre 2026

Les **10 contrôles** passent avec le Go **1.26.8 Linux ARM64** du conteneur ; les
contrôles de contrats et le contrôle natif passent également sur macOS avec Go
**1.27.0**. Trois lancements réels de `Ping` renvoient `pong`, dont une relance
sans compilation ni lien.

Sur une copie b8x reconstruite depuis **2 688 TAST**, cinq paires alternées
mesurent le runner jusqu'à `exec` du binaire de tests, avec les mêmes Go, caches
et paramètres `2 / 1 / 12GiB` :

| Relance à cache chaud | Ancien runner | Runner avec réutilisation |
| --- | ---: | ---: |
| Médiane jusqu'à `exec` | 1,812 s | 0,745 s |
| Compilations / liens | 0 / 1 | 0 / 0 |

**Gain médian : 58,9 %.** Les dix invocations produisent le même exécutable à
l'octet près. Le chronométrage s'arrête avant l'exécution de la suite métier :
`Test.Main` utilise directement `runSpecAndGetResults` et ne traite pas `--help`.

Les cinq échantillons après sont conservés, dont un à **11,008 s** avec seulement
0,280 s dans Go : le gain médian n'est pas une borne de latence. Le build initial,
qui a nécessité une préparation ponctuelle à `18GiB`, est exclu de cette mesure.
Le [bilan du lot 01](../../gopurs/gopurs/docs/testing.md#plan-v3--lot-01--réutilisation-des-exécutables-b8x-10-octobre-2026)
donne le protocole, les empreintes, les incidents de préparation et les preuves.
