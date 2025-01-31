pipeline {
    agent any

    environment {
        CONTAINER_ID = ''
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'  // Assuming the Dockerfile is in the root of the workspace
        TEST_FILE_PATH = 'variables.txt'
        DOCKERHUB_REPO = 'kaloucha55/projetjenkins'  // Replace with your DockerHub repository
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    bat "docker build -t sum_app -f ${DIR_PATH}/Dockerfile ${DIR_PATH}"
                }
            }
        }
        stage('Run') {
            steps {
                script {
                    echo "Running Docker container..."
                    // Remove existing container if any
                    bat 'docker rm -f sum_container || exit 0'
                    // Launch a new container
                    bat 'docker run -d --name sum_container sum_app'
                    // Wait a few seconds to make sure the container is running
                    bat 'timeout /t 5'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo "Running the sum.py script in the Docker container..."
                    // Execute the Python script inside the container
                    bat "docker exec sum_container python /app/sum.py 5 10"
                }
            }
        }
        stage('Deploy') {
            when {
                expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
            }
            steps {
                script {
                    echo "Logging in to DockerHub..."
                    // Using DockerHub credentials with 'withCredentials'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        bat "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
                    }
                    echo "Tagging the Docker image..."
                    bat "docker tag sum_app ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:latest"
                    echo "Pushing the Docker image to DockerHub..."
                    bat "docker push ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:latest"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Stopping and removing Docker container..."
                bat 'docker stop sum_container || exit 0'
                bat 'docker rm sum_container || exit 0'
            }
        }
    }
}
