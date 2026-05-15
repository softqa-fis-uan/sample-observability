FROM node:lts

RUN apt update
RUN apt install -y curl
RUN npm install -g pnpm

COPY package.json /tmp/package.json

# Safely install sentry-cli globally using Sentry's modern install hook
RUN curl -fsSL https://cli.sentry.dev/install | bash
# Tell the Node package installer to completely skip trying to download its own copy
ENV SENTRYCLI_SKIP_DOWNLOAD=1
RUN cd /tmp && pnpm install --ignore-scripts
RUN mkdir -p /frontend && cp -a /tmp/node_modules /frontend

WORKDIR /frontend
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
