pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'your-dockerhub-username'
        IMAGE_NAME = "jspgram"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/your-repo/jspgram.git'
            }
        }

        stage('Build WAR File') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u ${DOCKERHUB_USER} --password-stdin"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy on Server') {
            steps {
                sshagent(['server-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@your-server-ip "
                        docker pull ${DOCKERHUB_USER}/${IMAGE_NAME}:latest &&
                        docker stop jspgram || true &&
                        docker rm jspgram || true &&
                        docker run -d --name jspgram -p 8080:8080 ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        "
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline Completed"
        }
    }
}
