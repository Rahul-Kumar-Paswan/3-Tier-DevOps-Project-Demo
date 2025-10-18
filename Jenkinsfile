pipeline {
    agent any

    environment {
        BRANCH_NAME = "${env.BRANCH_NAME}"
    }

    stages {
        stage('Preparation') {
            steps {
                echo "📦 Branch Name: ${BRANCH_NAME} cleaned.."
            }
        }

        stage('Trigger Check') {
            when {
                expression { BRANCH_NAME == 'dummy-1' }
            }
            steps {
                echo "✅ This pipeline was triggered by a merge into 'dummy-1' branch."
            }
        }

        stage('Do Nothing') {
            when {
                not {
                    branch 'dummy'
                }
            }
            steps {
                echo "⛔️ Not 'dummy' branch — no further steps will run."
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline execution completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}
