pipeline {
    agent any

    environment {
        CONTAINER_ID = ''
        SUM_PY_PATH = 'C:\Users\larab\jenkins-docker-tp\jenkins-docker-tp\sum.py'  // Chemin vers le fichier sum.py dans le conteneur Docker
        DIR_PATH = 'C:\Users\larab\jenkins-docker-tp\jenkins-docker-tp\Dockerfile'  // Chemin vers le répertoire contenant le Dockerfile
        TEST_FILE_PATH = 'C:\Users\larab\jenkins-docker-tp\jenkins-docker-tp\variables.txt'  // Chemin vers votre fichier variables.txt
        DOCKERHUB_USERNAME = 'kaloucha55'  // Votre nom d'utilisateur DockerHub
        DOCKERHUB_REPO = 'kaloucha55/getting-started'  // Le nom de votre dépôt DockerHub
    }

    stages {
        // Etape 2 : Build Docker Image
        stage('Build') {
            steps {
                script {
                    // Construction de l'image Docker
                    echo "Building Docker image..."
                    sh "docker build -t sum_app ${DIR_PATH}"
                }
            }
        }

        // Etape 3 : Run Docker Container
        stage('Run') {
            steps {
                script {
                    // Exécution du conteneur Docker et récupération de l'ID
                    echo "Running Docker container..."
                    def output = sh(script: "docker run -d --name sum_container sum_app", returnStdout: true).trim()
                    CONTAINER_ID = output
                    echo "Container started with ID: ${CONTAINER_ID}"
                }
            }
        }

        // Etape 4 : Test Python Script
        stage('Test') {
            steps {
                script {
                    // Lecture du fichier test variables.txt
                    def testLines = readFile(TEST_FILE_PATH).split('\n')
                    testLines.each { line ->
                        def vars = line.split(' ')
                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()

                        // Exécution du script Python à l'intérieur du conteneur Docker
                        def output = sh(script: "docker exec ${CONTAINER_ID} python ${SUM_PY_PATH} ${arg1} ${arg2}", returnStdout: true).trim()

                        // Comparaison avec la somme attendue
                        def result = output.toFloat()
                        if (result == expectedSum) {
                            echo "Test passed for input: ${arg1} + ${arg2}. Expected sum: ${expectedSum}, got: ${result}"
                        } else {
                            error "Test failed for input: ${arg1} + ${arg2}. Expected sum: ${expectedSum}, but got: ${result}"
                        }
                    }
                }
            }
        }

        // Etape 5 : Post - Stop and Remove Docker Container
        post {
            always {
                script {
                    // Arrêter et supprimer le conteneur Docker, qu'il y ait un succès ou un échec
                    echo "Stopping and removing Docker container..."
                    sh "docker stop ${CONTAINER_ID}"
                    sh "docker rm ${CONTAINER_ID}"
                }
            }
        }

        // Etape 6 : Deploy to DockerHub
        stage('Deploy') {
            steps {
                script {
                    // Connexion à DockerHub
                    echo "Logging in to DockerHub..."
                    sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
                    
                    // Taguer l'image Docker
                    echo "Tagging the Docker image..."
                    sh "docker tag sum_app ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:latest"
                    
                    // Pousser l'image vers DockerHub
                    echo "Pushing the Docker image to DockerHub..."
                    sh "docker push ${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO}:latest"
                }
            }
        }
    }
}
