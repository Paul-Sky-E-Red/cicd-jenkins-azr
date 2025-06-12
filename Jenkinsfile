// This Jenkinsfile is used to build a Docker image, create a Helm chart, and push both to Azure Container Registry.
pipeline {
    agent any
    environment {
        AZURECREDENTIALS = credentials('azure-credentials')
        REPOSITORY = "registrykurs1.azurecr.io"
        CREATOR = "paul-dev" // Please adjust your name
        APPNAME = "${env.CREATOR}-sky-webapp"
        DOCKERIMAGE = "${env.CREATOR}/${env.APPNAME}"
        PUBLIC_FQDN = "k3s-master01.westus2.cloudapp.azure.com"
        IMAGE_TAG = "0.0.${env.BUILD_ID}"
    }
    stages {
        stage('Build Image') {
            steps {
                sh '''#!/bin/bash
                cd container
                echo "Changing names in welcome.html"
                echo ""
                sed -i -e "s/REPOSITORY/${REPOSITORY}/g" welcome.html && echo "REPOSITORY changed to ${REPOSITORY}"
                sed -i -e "s/DOCKERIMAGE/${CREATOR}\\/${APPNAME}/g" welcome.html && echo "DOCKERIMAGE changed to ${DOCKERIMAGE}"
                sed -i -e "s/BUILD_ID/${IMAGE_TAG}/g" welcome.html && echo "BUILD_ID changed to ${IMAGE_TAG}"
                echo "Building a new container image: ${DOCKERIMAGE}:$IMAGE_TAG"
                docker build -t ${DOCKERIMAGE}:$IMAGE_TAG .
                '''
            }
        }

        stage('Build Helmchart') {
            steps {
                sh '''#!/bin/bash
                echo "Building a new helmchart..."
                #cd helm
                #cd helm && mv webapp ${APPNAME}
                cd helm && cp -r webapp ${APPNAME} && rm -rf webapp # das sollte eigentlich funktionieren
                sed -i -e "s/webapp/${APPNAME}/g" ${APPNAME}/Chart.yaml
                echo "Building a new helmchart: ${DOCKERIMAGE} with Version: $IMAGE_TAG"
                helm package --app-version "$IMAGE_TAG" --version "$IMAGE_TAG" ${APPNAME}/ || exit 1
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''#!/bin/bash
                echo "Login to Azure Container Registry: ${REPOSITORY}"
                docker login -u $AZURECREDENTIALS_USR -p $AZURECREDENTIALS_PSW ${REPOSITORY}

                echo "Tagging the new container image: ${DOCKERIMAGE}:$IMAGE_TAG"
                docker tag ${DOCKERIMAGE}:$IMAGE_TAG ${REPOSITORY}/${DOCKERIMAGE}:$IMAGE_TAG

                echo "Pushing the new container image: ${DOCKERIMAGE}:\$IMAGE_TAG"
                docker push ${REPOSITORY}/${DOCKERIMAGE}:$IMAGE_TAG
                '''
            }
        }
        
        stage('Push Helmchart') {
            steps {
                sh '''#!/bin/bash
                cd helm
                echo "Login to Azure Container Registry: ${REPOSITORY}"
                helm registry login ${REPOSITORY} -u $AZURECREDENTIALS_USR -p $AZURECREDENTIALS_PSW 

                echo "Pushing the new helmchart package: ${APPNAME}-${IMAGE_TAG}.tgz to registry: ${REPOSITORY}/${DOCKERIMAGE}-helm"
                helm push ${APPNAME}-${IMAGE_TAG}.tgz oci://${REPOSITORY}/${DOCKERIMAGE}-helm || exit 1
                '''
            }
        }
        stage('Genereate Kubernetes Manifest') {
            steps {
                sh '''#!/bin/bash
                cd k8s
                echo "Changing names in example-flux.yaml"
                sed -e "s/example-webapp/${APPNAME}/g" -e "s/example-ns/${CREATOR}/g" -e "s/example-repo/${REPOSITORY}\\/${CREATOR}/g" -e "s/example-tag/${IMAGE_TAG}/g" example-flux.yaml | tee flux.yaml
                echo ""
                echo "Changing names in example-webapp.yaml"
                echo ""
                sed -e "s/example-webapp/${APPNAME}/g" -e "s/example-ns/${CREATOR}/g" -e "s/example-image-path/${REPOSITORY}\\/${CREATOR}\\/${APPNAME}/g" -e "s/example-tag/${IMAGE_TAG}/g" -e "s/example-fqdn/${PUBLIC_FQDN}/g" example-webapp.yaml | tee webapp.yaml
                echo ""
                echo "Changing names in example-helm.yaml"
                echo ""
                sed -e "s/example-webapp/${APPNAME}/g" -e "s/example-ns/${CREATOR}/g" -e "s/example-image-path/${REPOSITORY}\\/${CREATOR}\\/${APPNAME}/g" -e "s/example-repo/${REPOSITORY}\\/${CREATOR}/g" -e "s/example-tag/${IMAGE_TAG}/g" -e "s/example-helm-path/${REPOSITORY}\\/${CREATOR}\\/${APPNAME}-helm/g" -e "s/example-fqdn/${PUBLIC_FQDN}/g" example-helm.yaml | tee helm.yaml
                '''
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
