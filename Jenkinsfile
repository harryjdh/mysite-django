pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "harryjdh/mysite"
        DOCKERHUB_CRED = "dockerhub"      // Docker Hub credential ID
        IMAGE_TAG = "${BUILD_NUMBER}"
        GIT_CRED = "github-token"         // GitHub PAT credential ID
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
                withCredentials([
                    usernamePassword(
                        credentialsId: DOCKERHUB_CRED,
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )
                ]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push $DOCKERHUB_REPO:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Update K8s Manifest') {
            steps {
                withCredentials([
                    string(credentialsId: GIT_CRED, variable: 'TOKEN')
                ]) {
                    sh """
                        git config --global user.email "jenkins@mysite.com"
                        git config --global user.name "Jenkins CI"

                        git clone https://${TOKEN}@github.com/harryjdh/mysite-manifests.git manifests

                        cd manifests

                        sed -i "s|harryjdh/mysite:.*|harryjdh/mysite:${IMAGE_TAG}|g" deployment.yaml

                        git add deployment.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG}" || true
                        git push origin master
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Image pushed + Manifest updated to tag: $IMAGE_TAG"
        }
    }
}

