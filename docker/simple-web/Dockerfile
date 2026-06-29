# Stage 1: build
FROM node:24-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY src ./src

RUN mkdir -p dist && cp src/index.html dist/index.html

# Stage 2: runtime
FROM nginxinc/nginx-unprivileged:1.31.2-alpine

USER root
RUN apk upgrade --no-cache libexpat

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

USER 101

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]