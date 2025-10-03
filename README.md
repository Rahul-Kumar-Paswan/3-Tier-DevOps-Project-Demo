# ☸️ 3-Tier DevSecOps Project — Kubernetes Edition

This project demonstrates a **Kubernetes-based deployment** of a 3-tier full-stack web application.  
It builds upon the **local** and **Docker Compose** versions of this project by introducing **Kubernetes-native concepts** such as Deployments, Services, ConfigMaps, and Secrets.

---

## 🧱 Architecture Overview
| **Layer**    | **Stack**                            |
| ------------ | ------------------------------------ |
| **Frontend** | React.js + NGINX                     |
| **Backend**  | Node.js + Express + JWT              |
| **Database** | MySQL 8 (StatefulSet + PVC)          |
| **Platform** | Kubernetes                           |
| **Secrets**  | Kubernetes Secrets, ConfigMaps       |
| **Auth**     | JWT (Role-based login: Admin/Viewer) |

---

## 🔄 Environment Handling Across Stages

We use different strategies for environment variables:

- **Local Development (`.env.local`)**
  - Backend connects to `localhost`
  - Frontend API points to `http://localhost:5000/api`

- **Docker (`.env.docker`)**
  - Backend connects to `mysql` container
  - Frontend API uses relative path `/api` (Nginx reverse proxy)

- **Production / Kubernetes**
  - Environment variables are injected via **Secrets** and **ConfigMaps**
  - Backend DB host = `mysql` (K8s Service name)
  - Frontend API host = `backend-svc` (K8s Service name)

This ensures that **only the environment definitions change**, while code remains the same.

---

## 🔧 Prerequisites

Ensure the following tools are installed before proceeding:

kubectl: Command-line tool for interacting with Kubernetes.

Minikube or access to a Kubernetes Cluster (for local or cloud-based deployment).

Docker: For building container images.

Access to a Container Registry (e.g., Docker Hub) to push the Docker images.

---

## 📁 Project Structure

This project is organized as follows:

3-Tier-DevOps-Project-Demo/

├── LICENSE                              # Project license file
├── README.md                            # This documentation file
├── api/                                 # Backend (Node.js + Express) code
│   ├── Dockerfile                       # Dockerfile for building the backend image
│   ├── app.js                           # Main app file for the backend
│   ├── ..............                   # Backend route controllers
│

├── client/                              # Frontend (React) code
│   ├── Dockerfile                       # Dockerfile for building the frontend image
│   ├── default.conf.template            # NGINX configuration template
│   └── src/....                         # React components and app logic

├── kubernetes/                          # Kubernetes deployment files
│   ├── app-configs.yaml                 # Kubernetes ConfigMaps and Secrets
│   ├── backend-deployment.yaml          # Backend Kubernetes deployment and service
│   ├── frontend-deployment.yaml         # Frontend Kubernetes deployment and service
│   ├── mysql-deployment.yaml            # MySQL StatefulSet, services, and resources
│   ├── mysql-initdb-config.yaml         # MySQL initialization script config
│   ├── mysql-secret.yaml                # MySQL root user secret and password
│   └── sc.yaml                          # StorageClass for persistent volumes (optional)


---

## 📦 Build & Push Docker Images

### Backend
```bash
cd api/
docker build -t <your_dockerhub>/3tierdevsecops-backend:v1.0 .
docker push <your_dockerhub>/3tierdevsecops-backend:v1.0
```
### Frontend
```bash
cd ../client/
docker build -t <your_dockerhub>/3-tier-devops-project-frontend:v1.0 .
docker push <your_dockerhub>/3-tier-devops-project-frontend:v1.0
```

## ☸️ Deploy on Kubernetes
1️⃣ Create Namespace

Create a Kubernetes namespace to isolate resources:
```bash
kubectl create ns prod
```
2️⃣ Apply Secrets

Create secrets for MySQL and JWT:
```bash
kubectl apply -f kubernetes/mysql-secret.yaml -n prod
```
This includes:

mysql-secret → MySQL root user credentials

jwt-secret → JWT signing secret for backend authentication

3️⃣ Apply ConfigMaps
```bash
kubectl apply -f kubernetes/app-configs.yaml -n prod
kubectl apply -f kubernetes/mysql-initdb-config.yaml -n prod
```
frontend-config → React frontend environment (API URL)

backend-config → Backend configuration (ports, host)

mysql-config → MySQL database name

mysql-initdb-config → Init SQL script for DB schema + admin user

4️⃣ Deploy MySQL (Database)
```bash
kubectl apply -f kubernetes/mysql-deployment.yaml -n prod
```
This creates:

MySQL StatefulSet with PVC for persistent storage

mysql-db service for internal access

5️⃣ Deploy Backend (Node.js + Express)
```bash
kubectl apply -f kubernetes/backend-deployment.yaml -n prod
```
Connects to MySQL using env vars injected from Secrets + ConfigMaps

Uses backend-svc service for frontend communication

6️⃣ Deploy Frontend (React + Nginx)
```bash
kubectl apply -f kubernetes/frontend-deployment.yaml -n prod
```
React app served via Nginx

Communicates with backend via http://backend-svc:5000/api


## 🌐 Access the Application

To access the frontend application, use port forwarding:
```bash
kubectl port-forward svc/frontend-svc -n prod 8080:80
```

Now, visit the frontend at:

Frontend: http://localhost:8080

Optionally, to access the backend:
```bash
kubectl port-forward svc/backend-svc -n prod 5000:5000
```

## 📌 DNS Naming in Kubernetes

Within the same namespace: You can refer to the service by its name (e.g., backend-svc).

Across namespaces: Use service-name.namespace.

Fully Qualified Name: service-name.namespace.svc.cluster.local.

In your app, always use the Kubernetes Service name (e.g., backend-svc) for service discovery.

## 🔐 Secrets & ConfigMaps

Secrets and ConfigMaps are injected as environment variables. For example:
```bash
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mysql-secret
        key: MYSQL_ROOT_PASSWORD
```

## 🧪 Debugging Tips

If something goes wrong, use these commands to inspect and debug:

View all resources in the prod namespace:
```bash
kubectl get all -n prod
```

Check logs of the backend deployment:
```bash
kubectl logs -n prod deployment/backend
```

Exec into a pod for deeper inspection:
```bash
kubectl exec -it pod-name -n prod -- bash
```

Check DB connectivity:
```bash
mysql -h mysql -u root -p
```

## ✅ Features Recap

JWT-based authentication with role-based access (Admin/Viewer).

Preloaded MySQL schema using init.sql.

Fully containerized architecture.

Works seamlessly on Minikube or a Kubernetes cluster.

Modular YAML manifests for easy management.

Token-based middleware for backend API protection.

Service discovery via Kubernetes DNS.

## 🐞 Common Issues
| **Problem**                      | **Solution**                                                        |
| -------------------------------- | ------------------------------------------------------------------- |
| Frontend error: 401 Unauthorized | Ensure JWT token is passed in the request header.                   |
| Backend can't reach MySQL        | Verify that `DB_HOST=mysql` is correct and check pod logs.          |
| CrashLoopBackOff                 | Run `kubectl logs` to inspect environment variables and secrets.    |
| Frontend can't reach Backend     | Ensure `BACKEND_HOST` is correctly set to the backend service name. |


## 🧼 Clean Up Resources

If you need to clean up the deployed resources:
```bash
kubectl delete all --all -n prod
kubectl delete pvc --all -n prod
kubectl delete configmap --all -n prod
kubectl delete secret --all -n prod
kubectl delete ns prod
```

## 🚀 Future Enhancements

Ingress with TLS for secure access.

Integration with External Secrets Managers like Vault or Doppler.

Set up CI/CD pipelines with GitHub Actions.

Implement Monitoring (e.g., Prometheus + Grafana).

Package the app as a Helm Chart for easier deployment.

Enhance security with RBAC and Network Policies.


## 📝 License

MIT License © 2025 Rahul Paswan
This project is licensed under the [MIT License](./LICENSE).