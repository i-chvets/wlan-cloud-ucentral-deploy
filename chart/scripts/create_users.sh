#!/bin/sh
#
# Use this script to create DB initialization secret:
# kubectl create secret generic tip-openwifi-initdb-scripts --from-file=create_users.sh=create_users.sh -n <namespace>
#
OWGW_DB=owgw
OWGW_DB_USER=owgw
OWGW_DB_PASSWORD=owgw
OWSEC_DB=owsec
OWSEC_DB_USER=owsec
OWSEC_DB_PASSWORD=owsec
OWFMS_DB=owfms
OWFMS_DB_USER=owfms
OWFMS_DB_PASSWORD=owfms
OWPROV_DB=owprov
OWPROV_DB_USER=owprov
OWPROV_DB_PASSWORD=owprov
OWANALYTICS_DB=owanalytics
OWANALYTICS_DB_USER=owanalytics
OWANALYTICS_DB_PASSWORD=owanalytics
OWSUB_DB=owsub
OWSUB_DB_USER=owsub
OWSUB_DB_PASSWORD=owsub

# this is required in order for psql to connect to server
export PGPASSWORD=$PGPOOL_POSTGRES_PASSWORD
POSTGRES_SVC="pgsql-postgresql"

# wait for pgsql service to be up
until psql -h "$POSTGRES_SVC" --username "$PGPOOL_POSTGRES_USERNAME" postgres -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# create users and databases for all components
psql -v ON_ERROR_STOP=1 -h "$POSTGRES_SVC" --username "$PGPOOL_POSTGRES_USERNAME" postgres <<-EOSQL
  CREATE USER $OWGW_DB_USER WITH ENCRYPTED PASSWORD '$OWGW_DB_PASSWORD';
  CREATE DATABASE $OWGW_DB OWNER $OWGW_DB_USER;
  CREATE USER $OWSEC_DB_USER WITH ENCRYPTED PASSWORD '$OWSEC_DB_PASSWORD';
  CREATE DATABASE $OWSEC_DB OWNER $OWSEC_DB_USER;
  CREATE USER $OWFMS_DB_USER WITH ENCRYPTED PASSWORD '$OWFMS_DB_PASSWORD';
  CREATE DATABASE $OWFMS_DB OWNER $OWFMS_DB_USER;
  CREATE USER $OWPROV_DB_USER WITH ENCRYPTED PASSWORD '$OWPROV_DB_PASSWORD';
  CREATE DATABASE $OWPROV_DB OWNER $OWPROV_DB_USER;
  CREATE USER $OWANALYTICS_DB_USER WITH ENCRYPTED PASSWORD '$OWANALYTICS_DB_PASSWORD';
  CREATE DATABASE $OWANALYTICS_DB OWNER $OWANALYTICS_DB_USER;
  CREATE USER $OWSUB_DB_USER WITH ENCRYPTED PASSWORD '$OWSUB_DB_PASSWORD';
  CREATE DATABASE $OWSUB_DB OWNER $OWSUB_DB_USER;
EOSQL