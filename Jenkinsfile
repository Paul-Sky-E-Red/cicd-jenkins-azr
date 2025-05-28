// Define variables
def myName = "paul"
def myApplicationName = "sky-webapp"

// Excecute the pipeline
pipeline {
    agent any
    environment {
        AZURECREDENTIALS = credentials('azure-credentials')
        REPOSITORY = "myacr.azurecr.io"
    }
    stages {
        stage('Build Image') {
            steps {
                sh """#!/bin/bash
                DOCKERIMAGE="${myName}-${myApplicationName}"
                DOCKERTAG="0.0.$BUILD_TIMESTAMP"
                echo "Building a new container image: $DOCKERIMAGE:$DOCKERTAG"
                #docker build -t $DOCKERIMAGE:$DOCKERTAG .
                """
            }
        }
        
        stage('Build Helmchart') {
            steps {
                sh 'echo "Building a new helmchart..."'
            }
        }

        stage('Push Image') {
            steps {
                sh """#!/bin/bash
                echo "Login to Azure Container Registry: $REPOSITORY"
                #docker login -u $AZURECREDENTIALS_USR -p $AZURECREDENTIALS_PSW $REPOSITORY

                echo "Tagging the new container image: $DOCKERIMAGE:$DOCKERTAG"
                #docker tag $DOCKERIMAGE:$DOCKERTAG $REPOSITORY/$DOCKERIMAGE:$DOCKERTAG

                echo "Pushing the new container image: $DOCKERIMAGE:$DOCKERTAG"
                #docker push $REPOSITORY/$DOCKERIMAGE:$DOCKERTAG
                """
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
