FROM node:10
### install your dependencies if you have some
RUN mkdir /app && cd /app && npm install web3
COPY ./src /app
ENTRYPOINT [ "node", "/app/app.js"]