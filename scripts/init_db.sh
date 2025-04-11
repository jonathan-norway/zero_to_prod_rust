#!/usr/bin/env bash
set -x
set -eo pipefail
if ! [ -x "$(command -v sqlx)" ]; then
  echo >&2 "Error: sqlx is not installed."
  echo >&2 "Use: "
  echo >&2 "    cargo install --version='~0.8' sqlx-cli\
  --no-default-features --features rustls,postgres"
  exit 1
fi
DB_PORT="${POSTGRES_PORT:=1234}"
SUPERUSER="${SUPERUSER:=postgres}"
SUPERUSER_PWD="${SUPERUSER_PWD:=password}"

CONTAINER_NAME="postgres"

APP_USER="${APP_USER:=app}"
APP_USER_PWD="${APP_USER_PWD:=secret}"
APP_DB_NAME="${APP_DB_NAME:=newsletter}"

# Skip if already running container
if [[ -z "${SKIP_DOCKER}" ]]
then
  docker run \
    --env POSTGRES_USER=${SUPERUSER} \
    --env POSTGRES_PASSWORD=${SUPERUSER_PWD} \
    --health-cmd="pg_isready -U ${SUPERUSER} || exit 1" \
    --health-interval=1s \
    --health-timeout=5s \
    --health-retries=5 \
    --publish "${DB_PORT}:5432" \
    --detach \
    --name "${CONTAINER_NAME}" \
    postgres -N 1000


  # Wait for postgres to finish startup
  until [ \
    "$(docker inspect -f '{{.State.Health.Status}}' ${CONTAINER_NAME})" = \
    'healthy' \
  ]; do 
    >&2 echo "Postgres is still unavailable - sleeping"
    sleep 1
  done
  >&2 echo "Postgres is up and running on port ${DB_PORT}. Running migrations now!"

  # Create the application user
  CREATE_QUERY="CREATE USER ${APP_USER} WITH PASSWORD '${APP_USER_PWD}';"
  docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${CREATE_QUERY}"

  # Grant the application user privileges
  GRANT_QUERY="ALTER USER ${APP_USER} CREATEDB;"
  docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${GRANT_QUERY}"
fi
DATABASE_URL="postgres://${APP_USER}:${APP_USER_PWD}@localhost:${DB_PORT}/${APP_DB_NAME}"
export DATABASE_URL
sqlx database create
sqlx migrate run

echo >&2 echo "Postgres has been migration, ready to go!"