pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "harryjdh/mysite"
        DOCKERHUB_CRED = "dockerhub"
        IMAGE_TAG = "${BUILD_NUMBER}"
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
    }

    post {
        success {
            echo "Docker Image successfully pushed to DockerHub: $DOCKERHUB_REPO:$IMAGE_TAG"
        }
    }
}

