FROM nginx:${NGINX_VERSION:-stable-alpine}

COPY ./services/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./services/nginx/robots.txt /usr/share/nginx/robots.txt
