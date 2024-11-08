FROM node:lts

RUN apt update
RUN npm install -g pnpm

COPY package.json /tmp/package.json

RUN cd /tmp && pnpm install
RUN mkdir -p /frontend && cp -a /tmp/node_modules /frontend

WORKDIR /frontend
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
