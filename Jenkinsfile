pipeline {
    agent {
        label 'arm64 || amd64'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
    }
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'casjaysdevdocker/rarbg'
        DOCKER_BUILDKIT = '1'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Multi-Arch Image') {
            steps {
                script {
                    def buildArgs = ""
                    if (fileExists('.env.scripts')) {
                        buildArgs = "--build-arg-file .env.scripts"
                    }
                    
                    sh """
                        docker buildx create --use --name mybuilder || true
                        docker buildx build \\
                            --platform linux/amd64,linux/arm64 \\
                            --tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest \\
                            --tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:\${BUILD_NUMBER} \\
                            ${buildArgs} \\
                            --push .
                    """
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh """
                        docker run --rm --platform linux/\$(uname -m) \\
                            ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest \\
                            /bin/sh -c 'echo "Container test passed"'
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker buildx rm mybuilder || true'
            cleanWs()
        }
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}