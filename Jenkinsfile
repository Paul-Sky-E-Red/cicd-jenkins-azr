pipeline {
    agent any

    stages {
        stage('Build Image') {
            steps {
                sh 'echo "Building the new containerimage..."'
            }
        }
        
        stage('Build Helmchart') {
            steps {
                sh 'echo "Building a new helmchart..."'
            }
        }

        stage('Push Image') {
            steps {
                sh 'echo "Image will be tagged and pushed to Azure AZR..."'
            }
        }
        
        stage('Push Helmchart') {
            steps {
                sh 'echo "Helmchart will be pushed to Azure AZR..."'
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace'
            sh 'rm -rf ./*'
        }
        failure {
            echo 'Pipeline failure...'
        }
        success {
            echo 'Pipeline success...'
        }
    }
}
