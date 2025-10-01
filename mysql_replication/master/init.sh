#!/bin/bash

echo "Waiting for MySQL master to start..."
until mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1"; do
  echo "MySQL is unavailable - sleeping"
  sleep 2
done

echo "MySQL master is up - configuring replication..."

# Создаем пользователя репликации с mysql_native_password
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" << EOF
-- Создаем пользователя с правильным плагином аутентификации
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;

-- Создаем тестовую базу (она будет реплицироваться благодаря binlog_do_db)
CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;
CREATE TABLE IF NOT EXISTS example (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    data VARCHAR(100)
);

-- Добавляем начальные данные
INSERT INTO example (data) VALUES ('Initial data from master');
EOF

echo "Master initialization completed!"