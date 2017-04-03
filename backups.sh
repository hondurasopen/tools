#!/bin/bash
#=============================================================================================
# Script Backup Databases PostgreSQL - Tomeu Roig
# =============================================================================================

# Procedimiento de Copia de Seguridad de Servidor de Postgres

## BEGIN CONFIG ##
BACKUP_DIR="/var/backups/postgres/" #Dirección donde se guardaran
USER= administrator
FECHA=$(date +%d-%m-%Y)
FECHA_BORRADO=$(date +%d-%m-%Y --date='15 days ago')
BACKUP_DIR_TODAY=$BACKUP_DIR$FECHA/
## END CONFIG ##
export PGPASSWORD= administrator2014

if [ ! -d $BACKUP_DIR ]; then
mkdir -p $BACKUP_DIR
fi

echo $BACKUP_DIR_TODAY
if [ ! -d $BACKUP_DIR_TODAY ]; then
mkdir $BACKUP_DIR_TODAY
fi

#Leemos todas la bases de datos existente en Postgres, para despues realizar la copia una a una
POSTGRE_DBS=$(psql -U administrator -l | awk '(NR > 2) && (/[a-zA-Z0-9]+[ ]+[|]/) && ( $0 !~ /template[0-9]/) { print $1 }');
#Realizamos la copia de seguridad de cada una de ellas y las guardamos en un directorio de backups
for DB in $POSTGRE_DBS ; do
echo "* Backuping PostgreSQL data from $DB@$HOST ..."
pg_dump -U administrator --format=c -f $BACKUP_DIR_TODAY$DB.dump $DB

#Borramos las copias con una antiguedad mayor a 15 dias
rm -rf $BACKUP_DIR$FECHA_BORRADO
echo "finalizada $DB ..."
done

cd $BACKUP_DIR_TODAY
echo "...empaquetamos las DBs del $FECHA..."
tar czvf dbs-$FECHA.tar.gz *.dump

