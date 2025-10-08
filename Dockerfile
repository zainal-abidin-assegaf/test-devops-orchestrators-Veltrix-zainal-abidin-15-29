FROM node:18-alpine AS installer

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY . .

RUN npm run build

FROM node:18-alpine AS runner

WORKDIR /app

COPY --from=installer /app/node_modules node_modules
COPY --from=installer /app/dist dist
COPY --from=installer /app/package.json .
COPY --from=installer /app/package-lock.json .

RUN mkdir logs

CMD ["node", "dist/app.js"]