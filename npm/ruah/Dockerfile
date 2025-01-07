FROM node:slim AS npm_install
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
WORKDIR /ruah
RUN apt-get update && apt-get install curl gnupg -y \
	&& curl --location --silent https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
	&& apt-get update \
	&& apt-get install google-chrome-stable -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*
COPY package.json package-lock.json .
RUN npm install

FROM npm_install AS full_set
COPY . .

FROM full_set AS unitary_test
CMD npm test

FROM full_set AS build_module
RUN npm run build
CMD cat dist/hp.umd.js

FROM full_set AS integration_test
CMD npm run full_test

FROM build_module AS serve
CMD npm run serve

