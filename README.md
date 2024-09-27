# MySQL Data Dump and Import Project

## 프로젝트 개요
이 프로젝트는 Docker를 이용하여 MySQL 데이터베이스의 데이터를 덤프하고, 새로운 MySQL 데이터베이스에 반영하는 방법을 다룹니다. 주기적으로 데이터를 백업하고 새로운 데이터베이스에 임포트하는 자동화된 작업을 설정합니다.

## 목차
- [요구 사항](#요구-사항)
- [설치](#설치)
- [사용 방법](#사용-방법)
- [Cron 설정](#cron-설정)
- [볼륨 사용](#볼륨-사용)
- [파일 확인 방법](#파일-확인-방법)

## 요구 사항
- Docker
- Docker Compose

## 설치
1. **Docker 및 Docker Compose 설치**: 
   공식 문서를 참고하여 설치합니다.

2. **Docker Compose 파일 생성**:
   아래의 내용을 `docker-compose.yml` 파일에 저장합니다.

   ```yaml
   version: '3.8'
   services:
     mysql:
       container_name: mysql
       image: 'mysql:latest'
       environment:
         - 'MYSQL_DATABASE=fisa'
         - 'MYSQL_USER=newuser'
         - 'MYSQL_PASSWORD=root'
         - 'MYSQL_ROOT_PASSWORD=root'
       ports:
         - '3306:3306'
       volumes:
         - 'mysql_data:/var/lib/mysql'
     
     newmysqldb:
       container_name: newmysqldb
       image: 'mysql:latest'
       environment:
         - 'MYSQL_DATABASE=newfisa'
         - 'MYSQL_USER=newuser'
         - 'MYSQL_PASSWORD=root'
         - 'MYSQL_ROOT_PASSWORD=root'
       ports:
         - '3307:3306'
       volumes:
         - 'new_mysql_data:/var/lib/mysql'
   
   volumes:
     mysql_data:
     new_mysql_data:
   ```

## 사용 방법
1. **Docker Compose 실행**:
   ```bash
   docker-compose up -d
   ```
![image](https://github.com/user-attachments/assets/684c50da-6748-4b59-bc6d-411d107c5239)

2. **데이터 백업 및 임포트 스크립트 생성**:
   아래의 내용을 `backup_and_import.sh` 파일에 저장합니다.

   ```bash
   #!/bin/bash

   # 데이터 덤프
   docker exec mysql sh -c 'exec mysqldump -u root -p"root" fisa' > /home/username/mysqlDump/fisa_dump.sql

   # 덤프 파일 복사
   docker cp /home/username/mysqlDump/fisa_dump.sql newmysqldb:/fisa_dump.sql

   # 새로운 데이터베이스에 데이터 임포트
   docker exec -it newmysqldb bash -c 'mysql -u root -p"root" newfisa < /fisa_dump.sql'

   echo "데이터베이스 덤프 및 import가 완료되었습니다."
   ```

   스크립트에 실행 권한을 부여합니다:
   ```bash
   chmod +x /home/username/mysqlDump/backup_and_import.sh
   ```
![image](https://github.com/user-attachments/assets/74de0292-990a-419c-bb9b-da52fa498416)

3. **스크립트 실행**:
- 스크립트를 사용하여 crontab을 효율적으로 하도록 합니다.
   ```bash
   /home/username/mysqlDump/backup_and_import.sh
   ```
![image](https://github.com/user-attachments/assets/93799644-1b7e-472c-9961-ae42d62dafe5)


## Cron 설정
정기적으로 백업 및 임포트를 실행하기 위해 Cron을 설정합니다:
```bash
0 0 * * * /home/username/mysqlDump/backup_and_import.sh
```
![image](https://github.com/user-attachments/assets/65e2c8e5-95fa-46bd-bf56-51f6035bc1cb)

이렇게 설정하면 매일 자정에 백업 및 임포트가 실행됩니다.

## 볼륨 사용
Docker 볼륨을 사용하여 데이터의 지속성을 유지합니다. 각 컨테이너의 데이터는 `mysql_data` 및 `new_mysql_data` 볼륨에 저장됩니다.

## 파일 확인 방법
1. **복사된 파일 확인**:
   ```bash
   docker exec -it newmysqldb bash
   ls /fisa_dump.sql
   ```
 ![image](https://github.com/user-attachments/assets/fb5717b3-4d8c-4fe8-ab22-5619d0e1166e)


2. **파일 내용 확인**:
   ```bash
   cat /fisa_dump.sql
   ```
![image](https://github.com/user-attachments/assets/a1c831a2-3485-4cd9-8217-7eb5d0a89dd2)

3. **MySQL에서 데이터 확인**:
   ```bash
   mysql -u root -p"root" newfisa
   SHOW TABLES;
   SELECT * FROM test_table;
   ```
![image](https://github.com/user-attachments/assets/48b0a952-6279-4bc7-ba07-4d2a38532745)

## 결론
이 프로젝트를 통해 MySQL 데이터베이스의 데이터를 자동으로 덤프하고, 새로운 데이터베이스에 임포트하는 방법을 배울 수 있습니다. Cron을 사용하여 주기적으로 작업을 자동화할 수 있습니다.
