# Stage 1: Build React App
FROM node:22-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve with NGINX
FROM nginx:alpine

COPY --from=frontend /app/build /usr/share/nginx/html
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template

EXPOSE 80

CMD sh -c "envsubst '\$BACKEND_HOST \$BACKEND_PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
