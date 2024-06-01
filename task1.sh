#!/bin/bash

# Функция для вывода сообщения и записи его в лог
log_message() {
    local message="$1"
    echo "$message"
    echo "$message" >> script.log
}

# Проверка на наличие ключа -d
while getopts "d:" opt; do
    case $opt in
        d)
            base_dir="$OPTARG"
            ;;
        \?)
    esac
done

# Если ключ -d не задан, запросить директорию у пользователя
if [ -z "$base_dir" ]; then
    read -p "Введите путь до корневого каталога создания директорий: " base_dir
fi

# Проверка, что указанная директория существует и является директорией
if [ ! -d "$base_dir" ]; then
    mkdir "$base_dir"
fi

# Получение списка пользователей
users=$(getent passwd | awk -F: '{ if ($3 >= 1000 && $3 < 65534) print $1 }')

# Создание директорий для каждого пользователя
for user in $users; do
    user_dir="$base_dir/$user"
    if [ ! -d "$user_dir" ]; then
        mkdir "$user_dir"
        chmod 755 "$user_dir"
        chown "$user:$user" "$user_dir"
        log_message "Создана директория $user_dir с правами 755 и владельцем $user."
    else
        log_message "Директория $user_dir уже существует, пропуск."
    fi
done

exit 0
