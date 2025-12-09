pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "wordpress-cicd-jenkins:${env.BUILD_NUMBER}"
        DOCKER_COMPOSE_FILE = "docker-compose.yml"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/git-ejmm/wordpress-cicd-jenkins.git'
            }
        }

        stage('Static analysis') {
            steps {
                sh """
                cd wp-content/themes/cicd-theme
                composer install --no-interaction
                ./vendor/bin/phpstan analyse . --configuration=phpstan.neon || true
                """
            }
        }

        stage('Build image') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Test health') {
            steps {
                sh """
                docker compose -f ${DOCKER_COMPOSE_FILE} down || true
                docker compose -f ${DOCKER_COMPOSE_FILE} up -d
                sleep 30
                curl -f http://localhost:8081/wp-admin/install.php || true
                """
            }
        }

        stage('Security scan') {
            steps {
                sh """
                echo "Escaneo general Nuclei sobre http://localhost:8081 ..."
                nuclei -u http://localhost:8081 -severity medium,high,critical -silent || true

                echo "Escaneo especifico XSS en search-debug.php (plantilla custom) ..."
                nuclei -u http://localhost:8081 \
                       -t /var/lib/jenkins/nuclei-custom/wp-search-debug-xss.yaml || true
                """
            }
        }

        stage('Deploy') {
            steps {
                sh """
                docker compose -f ${DOCKER_COMPOSE_FILE} down || true
                docker compose -f ${DOCKER_COMPOSE_FILE} up -d --build
                """
            }
        }
    }

    post {
        always {
            sh "docker ps"
        }
    }
}
