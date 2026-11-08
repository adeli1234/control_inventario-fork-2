#!/usr/bin/env bash
# Respaldo de la base de datos en ./backups (restaurar: ver README)
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p backups
ARCHIVO="backups/panel_tienda_$(date +%F_%H%M).sql"
docker compose exec -T db sh -c 'mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" --routines --triggers --single-transaction "$DB_NAME"' > "$ARCHIVO"
echo "Respaldo creado: $ARCHIVO"
