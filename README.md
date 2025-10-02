# 🐳 3-Tier DevSecOps Project — Dockerized Environment

This is a **containerized 3-tier full-stack web application** with:

- **Backend API:** Node.js + Express.js
- **Frontend Client:** React.js + NGINX
- **Database:** MySQL 8
- **Auth:** JWT (admin/viewer roles)

Fully containerized with **Docker** and managed via **Docker Compose**.

---

## 🚀 Stack Overview

| Layer     | Tech Stack                 |
|-----------|----------------------------|
| Frontend  | React.js + NGINX           |
| Backend   | Node.js, Express, JWT      |
| Database  | MySQL 8                    |
| Auth      | JWT-based Auth             |
| DevOps    | Docker, Docker Compose     |

---

## ⚙️ Prerequisites

Ensure the following are installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

---

## 📁 Project Structure

```bash
.
├── docker-compose.yaml
├── mysql-init/init.sql       # Preloads DB schema
├── api/
│   ├── Dockerfile
│   ├── .env.docker
├── client/
│   ├── Dockerfile
│   ├── .env.docker
│   └── nginx/default.conf.template
```
---

## 🔐 Environment Variables

### ️ API – api/.env.docker

```env
MYSQL_ROOT_PASSWORD=Rahul@123
MYSQL_DATABASE=crud_app 
DB_NAME=crud_app
DB_HOST=mysql-db
DB_PORT=3306 
DB_USER=root 
DB_PASSWORD=Rahul@123 
JWT_SECRET=rahulverse 
ADMIN_NAME=Admin User 
ADMIN_EMAIL=admin@example.com 
ADMIN_PASSWORD=admin123 
ADMIN_ROLE=admin
```

### 🌐 Client client/.env.docker

```env
REACT_APP_API=/api 
BACKEND_HOST=3tierdevsecops-backend 
BACKEND_PORT=5000
```

### 🐳 Running the Application

From the project root:
```bash
docker-compose up --build
```

This will:

Start MySQL with initial schema from mysql-init/init.sql

Build and run the backend on port 5000

Build and serve React app via NGINX on port 3000

## 🌐 Access the App

🧑‍💻 Frontend: http://localhost:3000

🔐 Backend API: http://localhost:5000

## 📦 API Endpoints

| Method | Endpoint             | Description                |
| ------ | -------------------- | -------------------------- |
| POST   | `/api/auth/login`    | Login                      |
| POST   | `/api/auth/register` | Register new user          |
| GET    | `/api/users`         | Get all users (admin only) |

## ✅ Built-In Features

✅ Containerized with Docker

✅ NGINX for static frontend + proxying to backend

✅ MySQL schema initialized on startup

✅ Role-based login (Admin, Viewer)

## 🔮 Future Enhancements

CI/CD with GitHub Actions or Jenkins

Kubernetes deployment via Helm charts

Monitoring with Prometheus & Grafana

Secure secrets management (Vault, Doppler)

## 📝 License

MIT License © 2025 Rahul Paswan
This project is licensed under the [MIT License](./LICENSE).