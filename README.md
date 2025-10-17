# 🚀 3-Tier DevOps Project — Terraform | Jenkins | EKS | IRSA

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-181717?logo=github)](https://github.com/Rahul-Kumar-Paswan/3Tier-DevOps-Terraform)
[![Contributors](https://img.shields.io/github/contributors/Rahul-Kumar-Paswan/3Tier-DevOps-Terraform?color=blue)](https://github.com/Rahul-Kumar-Paswan/3Tier-DevOps-Terraform/graphs/contributors)
[![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20EC2%20%7C%20IRSA-orange?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-brightgreen?logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![CI/CD](https://img.shields.io/badge/Jenkins-CI%2FCD-orange?logo=jenkins)
![License](https://img.shields.io/badge/License-MIT-yellow)

A **production-grade DevOps project** that automates provisioning of a complete **3-tier AWS infrastructure** using **Terraform**, with a **Jenkins CI/CD pipeline** to create or destroy environments on demand.  
The architecture includes **VPC**, **EKS Cluster**, **IRSA**, and **EC2 instances** for DevOps tools like **SonarQube** and **Nexus**.

---

## 🧭 Table of Contents

- [🖥️ Project Overview](#️-project-overview)
- [📂 Project Structure](#-project-structure)
- [⚙️ Infrastructure Overview](#️-infrastructure-overview)
- [🔐 IAM and Security](#-iam-and-security)
- [📦 Jenkins Pipeline (CI/CD)](#-jenkins-pipeline-cicd)
- [🌍 Requirements & Deployment Guide](#-requirements--deployment-guide)
- [🧠 IRSA Notes](#-irsa-notes)
- [📊 Outputs](#-outputs)
- [🧼 Cost Optimization](#-cost-optimization)
- [🧑‍💻 Author](#-author)
- [📝 License](#-license)

---

## 🖥️ Project Overview

This project provisions and automates a **3-tier infrastructure** on AWS using Terraform and a Jenkins pipeline.

### 🔧 Infrastructure Includes:
- 🏗️ Custom VPC with public & private subnets  
- ☸️ EKS Cluster with managed node groups  
- 🔐 IRSA (IAM Roles for Service Accounts) integration  
- 💾 EBS CSI driver for dynamic volume provisioning  
- 💻 EC2 instances for SonarQube and Nexus with Docker  
- ⚙️ Automated Terraform create/destroy pipeline via Jenkins  

---

## 📂 Project Structure

```bash
.
├── Jenkinsfile                     # Jenkins pipeline (create/destroy)
├── README.md                       # Project documentation
├── envs/                           # Environment-specific tfvars
│   ├── dev.tfvars
│   └── prod.tfvars
├── main.tf                         # Root Terraform entry point
├── variables.tf                    # Global variable definitions
├── output.tf                       # Terraform outputs
├── terraform.tfvars                # Default variables (optional)
├── scripts/
│   └── install_docker.sh           # EC2 provisioning script
├── modules/                        # Reusable Terraform modules
│   ├── vpcs/                       # VPC, subnets, route tables, IGW
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── eks/                        # EKS cluster, IRSA roles, add-ons
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── variables.tf
│   │   └── policies/
│   │       └── jenkins-irsa-policy.json
│   └── ec2/                        # EC2 for SonarQube & Nexus (Docker)
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
```

---

## ⚙️ Infrastructure Overview

### 🧩 Modules

---

### 🏗️ VPC Module

- Creates a custom **VPC** with public and private subnets  
- Configures **Internet Gateway** and route tables  
- Tags subnets for **Kubernetes integration** (e.g., public/private subnet types)

---

### ☸️ EKS Module

- Provisions **Amazon EKS cluster** and **managed node groups**
- Configures **OIDC provider** for **IRSA (IAM Roles for Service Accounts)**
- Adds **Amazon EBS CSI driver** with IAM role binding
- Creates **IRSA roles** for:
  - `Jenkins` (CI/CD access to AWS)
  - `EBS CSI controller` (volume provisioning in Kubernetes)

---

### 💻 EC2 Module

- Launches **EC2 instances** for:
  - **Nexus** Repository Manager (`Port 8081`)
  - **SonarQube** Code Quality Tool (`Port 9000`)
- Configures EC2 startup with Docker using `scripts/install_docker.sh`

---
## 🔐 IAM and Security

- Uses **IRSA (IAM Roles for Service Accounts)** for secure, fine-grained pod-level AWS access  
- Follows **least-privilege** IAM role design principles  
- IAM roles provisioned:

  - `jenkins-irsa-role` → Provides AWS permissions to the **Jenkins pod** for CI/CD operations  
  - `ebs-csi-irsa-role` → Grants access to the **EBS CSI driver** for dynamic volume provisioning in Kubernetes  

---

## 📦 Jenkins Pipeline (CI/CD)

### 🧠 Pipeline Parameters

```groovy
parameters {
    choice(name: 'ACTION', choices: ['create', 'destroy'])
}
```

### 🪜 Pipeline Stages
| Stage                         | Description                                        |
| ----------------------------- | -------------------------------------------------- |
| **Checkout Code**             | Clones Terraform repository using `git-token`      |
| **Terraform Init + Validate** | Initializes and validates configuration            |
| **Terraform Apply**           | Executes `terraform apply` (if `ACTION=create`)    |
| **Terraform Destroy**         | Executes `terraform destroy` (if `ACTION=destroy`) |
| **Terraform Outputs**         | Displays useful infrastructure outputs             |

---

## 🔐 Jenkins Credentials Used
| ID              | Purpose                                            |
| --------------- | -------------------------------------------------- |
| **aws-cred**    | AWS IAM credentials for Terraform backend/provider |
| **prod-tfvars** | Custom `.tfvars` for production pipeline           |
| **git-token**   | GitHub token for repository access                 |

🧩 IRSA Note: If Jenkins runs in Kubernetes with IRSA enabled, you can remove aws-cred binding safely.

---
## 🌍 Requirements & Deployment Guide
### 🧰 Tools Required

| Tool          | Version | Purpose                           |
| ------------- | ------- | --------------------------------- |
| **Terraform** | ≥ 1.3   | Infrastructure as Code (IaC)      |
| **AWS CLI**   | ≥ 2.0   | AWS management and authentication |
| **kubectl**   | —       | Manage Kubernetes resources       |
| **Jenkins**   | —       | CI/CD pipeline automation         |

---
## 🚀 Deployment via Jenkins

- Configure Jenkins with the following credentials:
  - `aws-cred` (AWS credentials for Terraform)
  - `prod-tfvars` (Terraform variable file)
  - `git-token` (Git repository access token)

- Run the Jenkins pipeline and select the action:
  - `create` → Deploy infrastructure resources
  - `destroy` → Tear down and remove infrastructure resources

---
## 🧹 Manual Cleanup (Optional)
```bash
terraform destroy -auto-approve -var-file=envs/prod.tfvars
```
---

## 🧠 IRSA Notes

IAM Roles for Service Accounts (IRSA) allows Kubernetes pods to securely access AWS resources without requiring static AWS credentials.

### ⚙️ Configured With
- OIDC provider configured from the EKS cluster
- IAM role trust policy linked to the Kubernetes Service Account (SA)
- Example Kubernetes Service Account annotation:

```bash
eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/devsecops-jenkins-irsa-role
```

---
## 📊 Outputs

Terraform provides the following key outputs after deployment:

- **VPC ID**
- **Public and Private Subnet IDs**
- **EKS Cluster Name and Endpoint**
- **IAM Roles Created** (e.g., Jenkins IRSA Role, EBS CSI IRSA Role)
- **EC2 Instances Public IPs** (Nexus and SonarQube servers)

---
## 🧼 Cost Optimization

✅ **Before destroying, ensure:**

- All **Load Balancers**, **NAT Gateways**, and **EBS volumes** are cleaned up.  
- No lingering **EC2** or **EKS** resources remain to prevent unwanted charges.  

---

## 🧑‍💻 Author

**Rahul Kumar Paswan**  
GitHub: [@Rahul-Kumar-Paswan](https://github.com/Rahul-Kumar-Paswan)

---
## 📝 License

MIT License © 2025 Rahul Paswan
This project is licensed under the [MIT License](./LICENSE).