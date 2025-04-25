# Миграция с Nginx на Angie

load_module modules/ngx_rtmp_module.so;
load_module modules/ngx_http_brotli_filter_module.so;
load_module modules/ngx_http_brotli_static_module.so;

# Поиск путей
grep -rn '/nginx' /etc/angie
# Замена в конфигах
find . -type f -name '*.conf' -exec sed --follow-symlinks -i 's|/nginx|/angie|g' {} \;
grep -lr -e 'nginx' . | xargs sed -i 's/nginx/angie/g'
# Работа с символическими ссылками sites-enabled
find /etc/angie/sites-enabled/* -type l -printf 'ln -nsf "$(readlink "%p" | sed s!/etc/nginx/sites-available!/etc/angie/sites-available!)" "$(echo "%p" | sed s!/etc/nginx/sites-available!/etc/angie/sites-available!)"\n' > script.sh
chmod +x script.sh
./script.sh

# Тестирование конфигурации
sudo angie -t
# Переключение на Angie
sudo systemctl stop nginx && sudo systemctl start angie
# Включение автозагрузки
sudo systemctl disable nginx
sudo systemctl enable angie

# Восстановление команды docker run:
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
 assaflavie/runlike pmm-server

# Чтобы выяснить настройки контейнера:
docker inspect {ID|name}
#Запуск нового контейнера:
docker stop nginx && docker run --name angie …
docker rm nginx

# Собираем образ
docker build -t myangie .
# Запускаем контейнер
docker run --rm --name myangie -v /var/www:/usr/share/angie/html:ro \
    -v $(pwd)/angie.conf:/etc/angie/angie.conf:ro -p 8080:80 -d myangie

