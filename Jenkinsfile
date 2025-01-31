pipeline {
    agent any

    environment {
        CONTAINER_ID = ''
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'  // Assuming the Dockerfile is in the root of the workspace
        TEST_FILE_PATH = 'variables.txt'
        DOCKERHUB_REPO = 'kaloucha55/projetjenkins'  // Replace with your DockerHub repository
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'  // Jenkins credential ID for DockerHub
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
                    // Build the Docker image using the Dockerfile in the root directory
                    docker.build("sum_app", "${DIR_PATH}/Dockerfile")
                }
            }
        }
        stage('Run') {
            steps {
                script {
                    echo "Running Docker container..."
                    // Remove any existing container if there is one
                    bat 'docker rm -f sum_container || true'
                    // Run a new container from the built image
                    bat 'docker run -d --name sum_container sum_app'
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
                    // Use the DockerHub credentials stored in Jenkins
                    docker.withRegistry('https://index.docker.io/v1/', credentialsId: DOCKERHUB_CREDENTIALS) {
                        echo "Tagging the Docker image..."
                        // Tag the image with the DockerHub repository name
                        def image = docker.image('sum_app')
                        image.tag("${DOCKERHUB_REPO}:latest")
                        echo "Pubating the Docker image to DockerHub..."
                        // Pubat the image to DockerHub
                        image.pubat()
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Stopping and removing Docker container..."
                bat 'docker stop sum_container || true'
                bat 'docker rm sum_container || true'
            }
        }
    }
}
