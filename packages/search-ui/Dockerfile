# syntax=docker/dockerfile:1

# Build container
FROM docker.io/library/node:20-alpine3.17 as build

ARG VERSION
ENV VITE_VERSION=${VERSION}

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/search-ui ./packages/search-ui
RUN npm ci --workspace=search-ui --cache /tmp/empty-cache
RUN npm run build --workspace=search-ui

# Output container
FROM docker.io/nginxinc/nginx-unprivileged:1.23-alpine3.17

USER root

RUN rm -rf /usr/share/nginx/html/*
COPY --from=build --chown=$UID:$UID /app/dist /usr/share/nginx/html

USER $UID
