#!/bin/bash

# MySQL 컨테이너와 데이터베이스 정보
MYSQL_CONTAINER_NAME=mysql
NEW_DB_CONTAINER_NAME=newmysqldb
DB_NAME=fisa
NEW_DB_NAME=newfisa
DUMP_FILE_PATH="/home/username/mysqlDump/fisa_dump.sql"

# 새로운 데이터베이스 생성
docker exec $NEW_DB_CONTAINER_NAME sh -c "exec mysql -u root -p'root' -e 'CREATE DATABASE IF NOT EXISTS $NEW_DB_NAME;'"

# 데이터베이스 덤프
docker exec $MYSQL_CONTAINER_NAME sh -c "exec mysqldump -u root -p'root' $DB_NAME" > $DUMP_FILE_PATH

# 덤프 파일을 새로운 컨테이너로 복사
docker cp $DUMP_FILE_PATH $NEW_DB_CONTAINER_NAME:/fisa_dump.sql

# 새로운 데이터베이스에 덤프 파일을 import
docker exec -it $NEW_DB_CONTAINER_NAME sh -c "mysql -u root -p'root' $NEW_DB_NAME < /fisa_dump.sql"

echo "데이터베이스 덤프 및 import가 완료되었습니다."
