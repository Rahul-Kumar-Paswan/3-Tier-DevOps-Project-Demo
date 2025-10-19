pipeline {
    agent any

    tools {
        nodejs 'nodejs18'
    }

    environment {
        AWS_REGION                = "ap-south-1"
        DOCKER_REGISTRY           = "rahulkumarpaswan"
        FRONTEND_IMAGE            = "${DOCKER_REGISTRY}/3-tier-devops-project-frontend:${BUILD_NUMBER}"
        BACKEND_IMAGE             = "${DOCKER_REGISTRY}/3-tier-devops-project-backend:${BUILD_NUMBER}"
        BUILD_TAG                 = "${env.BUILD_NUMBER}"
        K8S_CLUSTER_NAME          = "devsecops-eks-cluster"
        NAMESPACE                 = "prod"
        SLACK_CHANNEL             = "#jenkins-notification"
        SCANNER_HOME              = tool 'sonar-scanner'
        SONAR_PROJECT_KEY_PREFIX  = "3tier"
    }

    parameters {
        choice(name: 'ACTION', choices: ['create', 'destroy'], description: 'Provision or destroy infrastructure')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'cicd', credentialsId: 'git-token', url: 'https://github.com/Rahul-Kumar-Paswan/3-Tier-DevOps-Project-Demo.git'
            }
        }

        stage('Terraform Init & Apply') {
            when { expression { params.ACTION == 'create' } }
            steps {
                withCredentials([
                    file(credentialsId: 'prod-tfvars', variable: 'TFVARS_FILE'),
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                ]) {
                    dir('./Infra') {
                        sh '''
                            terraform init
                            terraform validate
                            terraform plan -var-file=$TFVARS_FILE
                            terraform apply -auto-approve -var-file=$TFVARS_FILE
                        '''
                    }
                }
            }
        }

        stage('Syntax Check') {
            when { expression { params.ACTION == 'create' } }
            parallel {
                stage('Frontend') {
                    steps {
                        dir('client') {
                            sh 'find . -name "*.js" -exec node --check {} +'
                        }
                    }
                }
                stage('Backend') {
                    steps {
                        dir('api') {
                            sh 'find . -name "*.js" -exec node --check {} +'
                        }
                    }
                }
            }
        }

        stage('Gitleaks Secret Scan') {
            when { expression { params.ACTION == 'create' } }
            parallel {
                stage('Client Secrets') {
                    steps {
                        sh 'gitleaks detect --source ./client --exit-code 1'
                    }
                }
                stage('API Secrets') {
                    steps {
                        sh 'gitleaks detect --source ./api --exit-code 1'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            when { expression { params.ACTION == 'create' } }
            steps {
                script {
                    dir('client') {
                        withSonarQubeEnv('sonar') {
                            sh '''
                                $SCANNER_HOME/bin/sonar-scanner \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY_PREFIX}-frontend \
                                    -Dsonar.projectName=Frontend \
                                    -Dsonar.sources=.
                            '''
                        }
                    }
                    dir('api') {
                        withSonarQubeEnv('sonar') {
                            sh '''
                                $SCANNER_HOME/bin/sonar-scanner \
                                    -Dsonar.projectKey=${SONAR_PROJECT_KEY_PREFIX}-backend \
                                    -Dsonar.projectName=Backend \
                                    -Dsonar.sources=.
                            '''
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            when { expression { params.ACTION == 'create' } }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
                }
            }
        }

        stage('Trivy Filesystem Scan') {
            when { expression { params.ACTION == 'create' } }
            steps {
                sh 'trivy fs --format table -o fs-report.html .'
            }
        }

        stage('Build & Push Docker Images') {
            when { expression { params.ACTION == 'create' } }
            parallel {
                stage('Backend') {
                    steps {
                        script {
                            withDockerRegistry(credentialsId: 'docker-cred') {
                                dir('api') {
                                    sh """
                                        docker build -t ${BACKEND_IMAGE} .
                                        trivy image --format table -o backend-image-report.html ${BACKEND_IMAGE}
                                        docker push ${BACKEND_IMAGE}
                                    """
                                }
                            }
                        }
                    }
                }
                stage('Frontend') {
                    steps {
                        script {
                            withDockerRegistry(credentialsId: 'docker-cred') {
                                dir('client') {
                                    sh """
                                        docker build -t ${FRONTEND_IMAGE} .
                                        trivy image --format table -o frontend-image-report.html ${FRONTEND_IMAGE}
                                        docker push ${FRONTEND_IMAGE}
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { params.ACTION == 'create' }
            }
            steps {
                dir('./kubernetes/') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        script {
                            sh """
                                echo "🔐 Setting up AWS EKS credentials..."
                                aws eks --region ${AWS_REGION} update-kubeconfig --name ${K8S_CLUSTER_NAME}

                                echo "📦 Creating namespace if not exists..."
                                kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}

                                echo "📦 Exporting dynamic image names..."
                                export BACKEND_IMAGE=${BACKEND_IMAGE}
                                export FRONTEND_IMAGE=${FRONTEND_IMAGE}

                                echo "⚙️ Applying Kubernetes resources with envsubst where needed..."

                                # Apply files with dynamic image names
                                kubectl apply -n ${NAMESPACE} -f sc.yaml
                                kubectl apply -n ${NAMESPACE} -f mysql-secret.yaml
                                kubectl apply -n ${NAMESPACE} -f mysql-initdb-config.yaml
                                kubectl apply -n ${NAMESPACE} -f mysql-deployment.yaml
                                kubectl apply -n ${NAMESPACE} -f app-configs.yaml
                                envsubst < backend-deployment.yaml | kubectl apply -n ${NAMESPACE} -f -
                                envsubst < frontend-deployment.yaml | kubectl apply -n ${NAMESPACE} -f -

                                echo "⏳ Waiting for deployments to settle..."
                                sleep 30
                            """
                        }
                    }
                }
            }
        }

        stage('Verify Deployment') {
            when {
                expression { params.ACTION == 'create' }
            }
            steps {
                dir('./kubernetes/') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        script {
                            sh """
                            kubectl get pods -n ${NAMESPACE}
                            kubectl get svc -n ${NAMESPACE}
                        """
                        }
                    }
                }
            }
        }

        stage('Cleanup Kubernetes Resources') {
            when { expression { params.ACTION == 'destroy' } }
            steps {
                dir('./kubernetes/') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        script {
                            input message: '⚠️ Confirm infrastructure destroy?', ok: 'Proceed'

                            sh """
                                echo "🔐 Setting up kubeconfig for EKS..."
                                aws eks --region ${AWS_REGION} update-kubeconfig --name ${K8S_CLUSTER_NAME}

                                echo "🧹 Deleting entire namespace: ${NAMESPACE} ..."
                                kubectl delete ns ${NAMESPACE} || true

                                echo "⏳ Waiting for namespace to terminate..."
                                sleep 10
                                kubectl get ns
                            """
                        }
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.ACTION == 'destroy' } }
            steps {
                dir('./Infra') {
                    withCredentials([
                        file(credentialsId: 'prod-tfvars', variable: 'TFVARS_FILE'),
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']
                    ]) {
                        sh '''
                            terraform init
                            terraform plan -destroy -var-file=$TFVARS_FILE
                            terraform destroy -auto-approve -var-file=$TFVARS_FILE
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'good',
                message: "✅ SUCCESS: CI Build <${env.BUILD_URL}|#${BUILD_NUMBER}> completed successfully."
            )
        }
        failure {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'danger',
                message: "❌ FAILURE: CI Build <${env.BUILD_URL}|#${BUILD_NUMBER}> failed. Check Jenkins logs."
            )
        }
        always {
            script {
                if (fileExists('fs-report.html')) {
                    publishHTML([
                        reportDir: '.',
                        reportFiles: 'fs-report.html,frontend-image-report.html,backend-image-report.html',
                        reportName: 'Security Reports'
                    ])
                }
            }
        }
    }
}
