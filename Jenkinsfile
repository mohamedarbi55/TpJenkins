pipeline {
    agent any

    environment {
        CONTAINER_ID = ''
        SUM_PY_PATH = 'sum.py'
        DIR_PATH = '.'  // Assuming the Dockerfile is in the root of the workspace
        TEST_FILE_PATH = 'variables.txt'
        DOCKERHUB_USERNAME = 'mohamed.bouhejba%40edu.ece.fr'  // Remplacer '@' par '%40'
        DOCKERHUB_REPO = 'kaloucha55/projetjenkins'  // Remplace par ton repository DockerHub
        DOCKERHUB_PASSWORD = 'Larnibo55!!'  // Remplace par ton mot de passe DockerHub
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
                    // Supprimer le conteneur existant s'il y en a un
                    bat 'docker rm -f sum_container || true'
                    // Lancer un nouveau conteneur
                    bat 'docker run -d --name sum_container sum_app'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    echo "Running the sum.py script in the Docker container..."
                    // Exécuter le script Python à l'intérieur du conteneur
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
                    // Se connecter à DockerHub avec les informations définies dans les variables d'environnement
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
                bat 'docker stop sum_container || true'
                bat 'docker rm sum_container || true'
            }
        }
    }
}
