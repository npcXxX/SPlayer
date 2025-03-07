# build
FROM node:18-alpine as builder

RUN apk update && apk add --no-cache git

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN [ ! -e ".env" ] && cp .env.example .env || true

RUN npm run build

# nginx
FROM nginxinc/nginx-unprivileged:stable-alpine as app

# 使用 root 用户运行
USER root

COPY --from=builder /app/out/renderer /usr/share/nginx/html

COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache npm

RUN npm install -g NeteaseCloudMusicApi

CMD nginx && npx NeteaseCloudMusicApi
