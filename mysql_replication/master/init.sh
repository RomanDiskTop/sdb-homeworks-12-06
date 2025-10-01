#!/bin/bash


until mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1"; do
  sleep 2
done

# Создаем пользователя репликации с mysql_native_password
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" << EOF
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;
CREATE TABLE IF NOT EXISTS example (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    data VARCHAR(100)
);

INSERT INTO example (data) VALUES ('Initial data from master');
EOF

echo "Completed!"