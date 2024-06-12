FROM node:lts as dependencies
WORKDIR /dockerbuild
COPY package.json package-lock.json ./
RUN npm set strict-ssl false
RUN npm install

FROM node:lts as builder
WORKDIR /dockerbuild
COPY . .
COPY --from=dependencies /dockerbuild/node_modules ./node_modules
RUN npm run build

FROM node:lts as runner
WORKDIR /dockerbuild
ENV NODE_ENV production

COPY --from=builder /dockerbuild/public ./public
COPY --from=builder /dockerbuild/.next ./.next
COPY --from=builder /dockerbuild/node_modules ./node_modules
COPY --from=builder /dockerbuild/package.json ./package.json
COPY --from=builder /dockerbuild/next.config.js ./next.config.js

EXPOSE 3000
CMD npm run start 