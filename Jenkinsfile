pipeline {
    agent any

    environment {
        SUM_PY_PATH = "./sum.py"
        DIR_PATH = "./"
        TEST_FILE_PATH = "./variables.txt"
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    bat "docker build -t sum-calculator ${env.DIR_PATH}"
                }
            }
        }

        stage('Run') {
            steps {
                script {
                    echo "Running Docker container..."
                    def output = bat(
                        script: "docker run -d sum-calculator",
                        returnStdout: true
                    ).trim()

                    echo "Raw Output: ${output}"
                    def containerId = output.tokenize()[-1]?.trim()

                    if (!containerId) {
                        error "Failed to extract Docker container ID. Output: ${output}"
                    }

                    echo "Extracted Container ID: ${containerId}"
                    env.CONTAINER_ID = containerId
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Starting tests..."
                    def containerId = env.CONTAINER_ID
                    echo "Using Container ID: ${containerId}"

                    def testLines = readFile(env.TEST_FILE_PATH).split('\n')
                    for (line in testLines) {
                        def vars = line.split(' ')
                        if (vars.size() < 3) {
                            echo "Skipping invalid test line: ${line}"
                            continue
                        }

                        def arg1 = vars[0]
                        def arg2 = vars[1]
                        def expectedSum = vars[2].toFloat()

                        def output = bat(
                            script: "docker exec ${containerId} python /app/sum.py ${arg1} ${arg2}",
                            returnStdout: true
                        ).trim()

                        echo "Test Output: ${output}"
                    }
                }
            }
        }

        stage('Deploy to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                    usernameVariable: 'DOCKERHUB_USERNAME', 
                    passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    script {
                        echo "Logging into DockerHub securely..."
                        // Utilisation du token DockerHub pour l'authentification
                        bat """
                        docker login -u %DOCKERHUB_USERNAME% -p %DOCKERHUB_PASSWORD%
                        """

                        def imageName = "python-sum"
                        // Correction de la commande docker tag avec les bonnes variables
                         bat "docker tag python-sum wassim33/python-sum:latest"


                        echo "Pushing Docker image..."
                        // Poussée de l'image sur DockerHub
                        bat "docker push wassim33/python-sum:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
            script {
                bat "docker stop ${env.CONTAINER_ID} || true"
                bat "docker rm ${env.CONTAINER_ID} || true"
            }
        }
    }
}