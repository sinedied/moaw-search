# syntax=docker/dockerfile:1

# Build Node.js app
# ------------------------------------
FROM node:18-alpine as build
WORKDIR /app
COPY ./package*.json ./
COPY ./packages/search-api-node ./packages/search-api-node
RUN npm ci --cache /tmp/empty-cache
RUN npm run build --workspace=search-api-node

# Run Node.js app
# ------------------------------------
FROM node:18-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/search-api-node/package.json ./packages/search-api-node/
RUN npm ci --omit=dev --workspace=search-api-node --cache /tmp/empty-cache
COPY --from=build app/packages/search-api-node/dist packages/search-api-node/dist
EXPOSE 3000
CMD [ "npm", "start", "--workspace=search-api-node" ]
