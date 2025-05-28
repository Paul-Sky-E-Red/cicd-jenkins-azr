// This Jenkinsfile is used to build a Docker image, create a Helm chart, and push both to Azure Container Registry.
pipeline {
    agent any
    environment {
        AZURECREDENTIALS = credentials('azure-credentials')
        REPOSITORY = "tempregistrykurs1.azurecr.io"
        DOCKERIMAGE = "paul-sky-webapp" // Please change this to your desired Docker image name
    }
    stages {
        stage('Build Image') {
            steps {
                sh '''#!/bin/bash
                cd container
                echo "Building a new container image: \$DOCKERIMAGE:$BUILD_ID"
                docker build -t \$DOCKERIMAGE:$BUILD_ID .
                '''
            }
        }
        
        stage('Build Helmchart') {
            steps {
                sh '''#!/bin/bash
                echo "Building a new helmchart..."
                cd helm && mv webapp \$DOCKERIMAGE
                echo "Building a new helmchart: \$DOCKERIMAGE with Version: $BUILD_ID"
                helm package --app-version "$BUILD_ID" --version "$BUILD_ID" \$DOCKERIMAGE/ || exit 1
                '''

            }
        }

        stage('Push Image') {
            steps {
                sh '''#!/bin/bash
                echo "Login to Azure Container Registry: \$REPOSITORY"
                docker login -u $AZURECREDENTIALS_USR -p $AZURECREDENTIALS_PSW \$REPOSITORY

                echo "Tagging the new container image: \$DOCKERIMAGE:$BUILD_ID"
                docker tag \$DOCKERIMAGE:$BUILD_ID \$REPOSITORY/\$DOCKERIMAGE:$BUILD_ID

                echo "Pushing the new container image: \$DOCKERIMAGE:\$BUILD_ID"
                docker push \$REPOSITORY/\$DOCKERIMAGE:$BUILD_ID
                '''
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
