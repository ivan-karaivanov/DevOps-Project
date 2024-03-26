pipeline {
    agent any

    environment {
        IMAGE_NAME = "693363667837.dkr.ecr.eu-central-1.amazonaws.com/flasknew"
        REGION = "eu-central-1"
        PORT = 8080 // Assuming default Flask port
        CONTAINER_NAME = "flask_container"
    }

    stages {
        stage("Build") {
            steps {
                script {
                    // Log in to AWS ECR
                    withCredentials([string(credentialsId: 'aws-ecr-credentials', variable: 'AWS_ECR_CREDENTIALS')]) {
                        sh "echo $AWS_ECR_CREDENTIALS | base64 --decode | docker login --username AWS --password-stdin $REGION"
                    }

                    // Build Docker image
                    sh "docker build -t $IMAGE_NAME:latest ."
                }
            }
        }

        stage("Test") {
            steps {
                script {
                    // Test Flask application
                    def testResult = sh(script: "curl localhost:$PORT", returnStatus: true)
                    if (testResult == 0) {
                        echo "SUCCESSFUL TESTS"
                    } else {
                        error "FAILED TESTS"
                    }
                }
            }
        }

        stage("Push") {
            steps {
                script {
                    // Push Docker image to AWS ECR
                    sh "docker push $IMAGE_NAME:latest"
                }
            }
        }

        stage("Deploy") {
            steps {
                script {
                    // Deploy application using Helm
                    sh "helm upgrade flask helm/ --install --wait --atomic"
                }
            }
        }
    }

    post {
        always {
            // Cleanup
            sh "docker stop $CONTAINER_NAME || true"
            sh "docker rm $CONTAINER_NAME || true"
        }
    }
}

