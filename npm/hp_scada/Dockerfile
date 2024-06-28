FROM node:22.3.0-alpine3.20 as build_module
WORKDIR /package
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
CMD cat dist/hp.umd.js

