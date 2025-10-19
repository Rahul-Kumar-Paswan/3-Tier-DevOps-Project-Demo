# Stage 1: Build React App
FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Optional: pass REACT_APP_API as build arg
ARG REACT_APP_API
ENV REACT_APP_API=$REACT_APP_API

RUN npm run build

# Stage 2: Serve with NGINX
FROM nginx:alpine

# Copy React build output to NGINX html directory
COPY --from=build /app/build /usr/share/nginx/html

# Copy NGINX config template
COPY default.conf.template /etc/nginx/conf.d/default.conf.template

EXPOSE 80

# Substitute BACKEND_HOST env var dynamically and start nginx
CMD sh -c "envsubst '\$BACKEND_HOST' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
