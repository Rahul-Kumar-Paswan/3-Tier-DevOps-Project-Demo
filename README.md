# 🖥️ 3-Tier DevSecOps Project

This repository contains a simple Node.js API and a React client used for a user management demo. Follow the steps below to get the project running locally.

---

## 🚀 Project Overview

This is a **3-tier full-stack web application** with:

- **Backend API:** Node.js, Express, MySQL
- **Frontend Client:** React.js
- **Authentication:** JWT-based (login/register)
- **Role-based Access:** Admin and User roles

---

## 🧰 Technologies Used

| Layer        | Tech Stack            |
| ------------ | --------------------- |
| Frontend     | React.js, Axios       |
| Backend      | Node.js, Express, JWT |
| Database     | MySQL                 |
| Auth         | JWT-based auth        |

---

## ⚙️ Prerequisites

Ensure the following are installed on your system:

- **Node.js** (v18 or newer)
- **npm** (comes with Node.js)
- **MySQL** (running locally on default port `3306`)

---

## 🔐 Environment Variables

### Backend (`api/.env`)

Create a `.env` file inside the `api/` directory:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=crud_app

JWT_SECRET=your_jwt_secret

ADMIN_NAME=Admin User
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=admin123
ADMIN_ROLE=admin
```

### 🔧 Frontend (`client/.env`)

Create a `.env` file in the `client/` directory:

```env
REACT_APP_API=
```

## 🏁 Local Development Setup
1. Start MySQL

Make sure your MySQL server is running.

You can create the database manually:
```bash
mysql -u root -p

-- Inside MySQL shell:
CREATE DATABASE crud_app;
```

2. Install Dependencies
# Backend
```bash
cd api
npm install
```

# Frontend
```bash
cd ../client
npm install
```

3. Start the API Server
```bash
cd api
npm start
```

If successful, you should see:
🚀 Server running on http://0.0.0.0:5000
✅ MySQL `users` table found.

4. Start the React App
In a new terminal:
```bash
cd client
npm start
```
App should be running at:
👉 http://localhost:3000
The client now displays an animated banner welcoming you to **Rahulverse**.

## 📦 API Endpoints
| Method | Endpoint             | Description       |
| ------ | -------------------- | ----------------- |
| POST   | `/api/auth/login`    | User login        |
| POST   | `/api/auth/register` | User registration |
| GET    | `/api/users`         | Get users (admin) |

## 🛡️ Authentication & Roles

JWT tokens are stored in localStorage.

React frontend protects routes using ProtectedRoute.js.

Role-based access control via middleware (middleware/role.js).

## 📦 Future Enhancements

✅ Dockerize for containerized deployments

✅ CI/CD with GitHub Actions or Jenkins

✅ Helm chart for Kubernetes deployment

✅ Logging & Monitoring (Prometheus, Grafana)

✅ Environment-based configurations

## 📝 License

MIT License © 2025 Rahul Paswan
This project is licensed under the [MIT License](./LICENSE).