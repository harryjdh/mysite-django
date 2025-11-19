pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "harryjdh/mysite"
        DOCKERHUB_CRED = "dockerhub"
        IMAGE_TAG = "${BUILD_NUMBER}"
        GIT_CRED = "github-token"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t $DOCKERHUB_REPO:$IMAGE_TAG .
                """
            }
        }

        stage('Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CRED, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push $DOCKERHUB_REPO:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Update K8s Manifest') {
            steps {
                withCredentials([string(credentialsId: github-token, variable: 'TOKEN')]) {

                    sh """
                        git config --global user.email "jenkins@mysite.com"
                        git config --global user.name "Jenkins CI"

                        rm -rf mysite-manifests
                        git clone https://$TOKEN@github.com/harryjdh/mysite-manifests.git
                        cd mysite-manifests

                        sed -i "s|harryjdh/mysite:.*|harryjdh/mysite:${IMAGE_TAG}|g" deployment.yaml

                        git add deployment.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                        git push https://$TOKEN@github.com/harryjdh/mysite-manifests.git main
                    """
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Image pushed and manifest updated!"
        }
    }
}

