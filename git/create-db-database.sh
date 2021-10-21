if [ "$#" -ne 7 ]
then
	echo "Usage $0 <DB_HOST> <DB_ROOT_USER> <DB_ROOT_PASSWORD> <DB_SCHEMA> <NEW_DATABASE_NAME> <NEW_DATABASE_USER> <NEW_DATABASE_USER_PASSWORD>"
	exit 1
fi

DB_HOST=$1
DB_ROOT_USER=$2
DB_ROOT_PASSWORD=$3
DB_SCHEMA=$4
NEW_DATABASE_NAME=$5
NEW_DATABASE_USER=$6
NEW_DATABASE_USER_PASSWORD=$7

docker run --network=host -d --name=mysql-cli -e MYSQL_ROOT_PASSWORD=root mysql:5.7
sleep 5
echo "Creating database $NEW_DATABASE_NAME and user $NEW_DATABASE_USER..."
docker exec mysql-cli mysql --host="$DB_HOST" --user="$DB_ROOT_USER" --password="$DB_ROOT_PASSWORD" "$DB_SCHEMA" -e "CREATE DATABASE "$NEW_DATABASE_NAME";CREATE USER "$NEW_DATABASE_USER"@'%' identified by '"$NEW_DATABASE_USER_PASSWORD"';GRANT ALL ON $NEW_DATABASE_NAME.* TO '"$NEW_DATABASE_USER"'@'%';"

echo "Database created, test with new user and database"
docker exec -it mysql-cli mysql --host="$DB_HOST" --user="$NEW_DATABASE_USER" --password="$NEW_DATABASE_USER_PASSWORD" "$NEW_DATABASE_NAME" -e "show databases;"

docker stop mysql-cli && docker rm mysql-cli
