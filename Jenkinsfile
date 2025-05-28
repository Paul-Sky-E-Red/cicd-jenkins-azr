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
                BUILD_TIMESTAMP=$(date +%s)
                export DOCKERTAG="0.0.$BUILD_TIMESTAMP"
                echo "Building a new container image: \$DOCKERIMAGE:$DOCKERTAG"
                #docker build -t \$DOCKERIMAGE:$DOCKERTAG .
                '''
            }
        }
        
        stage('Build Helmchart') {
            steps {
                sh 'echo "Building a new helmchart..."'
            }
        }

        stage('Push Image') {
            steps {
                sh '''#!/bin/bash
                echo "Login to Azure Container Registry: \$REPOSITORY"
                #docker login -u $AZURECREDENTIALS_USR -p $AZURECREDENTIALS_PSW \$REPOSITORY

                echo "Tagging the new container image: \$DOCKERIMAGE:\$DOCKERTAG"
                #docker tag \$DOCKERIMAGE:\$DOCKERTAG \$REPOSITORY/\$DOCKERIMAGE:\$DOCKERTAG

                echo "Pushing the new container image: \$DOCKERIMAGE:\$DOCKERTAG"
                #docker push \$REPOSITORY/\$DOCKERIMAGE:\$DOCKERTAG
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
