pipeline {
    agent any

    environment {
        CONTAINER_ID = ''
        SUM_PY_PATH = 'sum.py'  
        DIR_PATH = '.'  // Assuming the Dockerfile is in the root of the workspace
        TEST_FILE_PATH = 'variables.txt'  
        DOCKERHUB_USERNAME = 'kaloucha55'  
        DOCKERHUB_REPO = 'kaloucha55/getting-started'  
    }

    stages {
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
            
            // Supprimer le conteneur existant s'il y en a un
            bat 'docker rm -f sum_container || true'
            
            // Lancer un nouveau conteneur et capturer son ID
            def output = bat(script: "docker run -d --name sum_container sum_app", returnStdout: true).trim()
            CONTAINER_ID = output
            echo "Container started with ID: ${CONTAINER_ID}"
        }
    }
}

stage('Test') {
    steps {
        script {
            echo "Running the sum.py script in the Docker container..."

            // Exécuter le script Python à l'intérieur du conteneur
            bat "docker exec ${CONTAINER_ID} python /app/sum.py 5 10"
        }
    }
}

        stage('Deploy') {
            steps {
                script {
                    echo "Logging in to DockerHub..."
                    bat "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
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
                bat "docker stop ${CONTAINER_ID}"
                bat "docker rm ${CONTAINER_ID}"
            }
        }
    }
}
