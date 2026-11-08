# Control de inventario – Mini centro de datos con Docker

Sistema de control de inventario para emprendedores (Flask + MariaDB) listo para correr en contenedores.

| Servicio | Imagen | Puerto | Para qué sirve |
|---|---|---|---|
| `web` | nginx:1.27-alpine | 80 | Servidor web: entrega CSS/JS y reenvía todo lo demás a la app |
| `app` | construida desde el `Dockerfile` (Python 3.12 + Flask + gunicorn) | interno 8000 | La aplicación y su conexión con la base de datos |
| `db` | mariadb:11.4 | 3306 (solo local) | Base de datos `panel_tienda` |
| `grafana` | grafana-oss:11.2.0 | 3000 | Monitoreo, ya conectado a la base de datos |

## Inicio rápido (Linux)

```bash
git clone https://github.com/TTREJOGONZALEZ/control_inventario-.git
cd control_inventario-
cp .env.example .env        # edita las contraseñas
docker compose up -d --build
docker compose ps           # los 4 deben estar "Up" (db "healthy")
```

- Aplicación: http://localhost
- Grafana: http://localhost:3000 (usuario `admin`, contraseña `GRAFANA_ADMIN_PASSWORD`)

En el `.env` evita comillas simples (`'`) y el signo `$` en las contraseñas. `SECRET_KEY` puede generarse con `openssl rand -hex 32`.

## Base de datos y volumen

La primera vez que arranca, MariaDB ejecuta en orden:

1. `database/panel_tienda_multitienda.sql` (tablas, vistas, trigger y procedimientos)
2. `database/actualizar_bd.sql` (agrega `costo_compra`)
3. `docker/db/03_usuarios.sh` (crea el usuario de la app y uno de solo lectura para Grafana)

**Solo corren cuando el volumen está vacío.** Para repetir la inicialización desde cero: `docker compose down -v` (¡borra los datos!).

| Volumen | Dentro del contenedor | Contiene |
|---|---|---|
| `db_data` | `/var/lib/mysql` | Todos los datos de MariaDB |
| `grafana_data` | `/var/lib/grafana` | Dashboards y configuración de Grafana |

Los datos se conservan aunque ejecutes `docker compose down`. Para ver dónde están en el disco: `docker volume inspect <proyecto>_db_data`.

### Respaldo y restauración

```bash
./scripts/backup.sh                                   # crea backups/panel_tienda_FECHA.sql
docker compose exec -T db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" "$DB_NAME"' < backups/ARCHIVO.sql
```

## Grafana

La fuente de datos "MariaDB panel_tienda" ya viene creada (usuario de solo lectura). Consultas útiles para paneles:

```sql
SELECT fecha AS time, SUM(ingresos) AS ingresos FROM v_ingresos_diarios GROUP BY fecha ORDER BY fecha;
SELECT producto, cantidad_disponible FROM v_alertas_stock;
SELECT producto, SUM(cantidad) AS vendidos FROM v_ventas GROUP BY producto ORDER BY vendidos DESC LIMIT 10;
```

## Correr sin Docker (desarrollo)

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
# en .env: DB_HOST=localhost y los datos de tu MySQL local
python app.py
```

## Flujo de trabajo (DevOps + Scrum)

- **Git**: `main` estable, una rama por tarea, Pull Request revisado por un compañero.
- **DevOps**: todo el entorno vive en el repositorio (compose, Dockerfile, SQL); cualquiera lo levanta con un comando. Las contraseñas van en `.env`, que no se sube.
- **Scrum**: sprints de 1–2 semanas. Ejemplo: Sprint 1 contenedores y base de datos; Sprint 2 conexión de la app; Sprint 3 Grafana y respaldos; Sprint 4 pruebas y documentación.

## Estructura

```
├── Dockerfile              imagen de la app (Python + gunicorn)
├── docker-compose.yml      nginx + app + MariaDB + Grafana, puertos y volúmenes
├── .env.example
├── app.py, db.py, templates/, static/      la aplicación
├── database/               scripts SQL
├── docker/db/03_usuarios.sh
├── nginx/default.conf
├── grafana/provisioning/datasources/mariadb.yml
└── scripts/backup.sh
```
