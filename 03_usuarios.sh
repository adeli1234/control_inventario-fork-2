#!/bin/bash
# Se ejecuta automáticamente después de los .sql, solo la primera vez que se crea el volumen.
# Crea el usuario de la app (permisos limitados) y uno de solo lectura para Grafana.
set -e
mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}" <<SQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
CREATE USER IF NOT EXISTS '${DB_GRAFANA_USER}'@'%' IDENTIFIED BY '${DB_GRAFANA_PASSWORD}';
GRANT SELECT ON \`${DB_NAME}\`.* TO '${DB_GRAFANA_USER}'@'%';
FLUSH PRIVILEGES;
SQL
