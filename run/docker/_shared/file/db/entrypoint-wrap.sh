#!/bin/bash
set -e

# Fonction pour gérer les signaux
_term() {
    echo "Caught signal, shutting down PostgreSQL..."
    kill -TERM "$PG_PID" 2>/dev/null
}

# Si la commande est 'postgres', on ajoute notre logique
if [ "$1" = 'postgres' ]; then
    # Ensure correct permissions for logical replication directories before start
    if [ -d "/var/lib/postgresql/data/pgdata/pg_logical" ]; then
        echo "Ensuring postgres owns pg_logical directories..."
        chown -R postgres:postgres "/var/lib/postgresql/data/pgdata/pg_logical"
    fi

    # Capturer les signaux pour un arrêt propre
    trap _term SIGTERM SIGINT

    # Démarrer PostgreSQL en arrière-plan
    /usr/local/bin/docker-entrypoint.sh "$@" &
    PG_PID=$!

    # Attendre que PostgreSQL soit prêt
    until pg_isready -U "$POSTGRES_USER" 2>/dev/null; do
        sleep 1
    done

    # Exécuter les scripts d'initialisation à chaque démarrage
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)     echo "Running $f"; . "$f" ;;
            *.sql)    echo "Running $f"; psql -U "$POSTGRES_USER" -d postgres -f "$f"; echo ;;
            *)        echo "Ignoring $f" ;;
        esac
    done

    # Attendre le processus PostgreSQL
    wait $PG_PID
else
    # Sinon, déléguer directement à l'entrypoint d'origine
    exec /usr/local/bin/docker-entrypoint.sh "$@"
fi
