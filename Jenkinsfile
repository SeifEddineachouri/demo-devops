pipeline {
    agent any

    tools {
        maven 'Maven 3.9.6'
        jdk 'JDK 17'
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_HOST_URL = 'https://sonarcloud.io'
        SONAR_ORGANIZATION = 'seifeddineachouri'
        SONAR_PROJECT_KEY = 'seifeddineachouri_demo-devops'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                    jacoco execPattern: '**/target/jacoco.exec'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                echo 'Running SonarCloud analysis...'
                withSonarQubeEnv('SonarCloud') {
                    sh """
                        mvn verify sonar:sonar \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.organization=${SONAR_ORGANIZATION} \
                        -Dsonar.host.url=${SONAR_HOST_URL}
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Checking Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                // Ajoutez ici vos étapes de déploiement
                sh 'echo "Application ready for deployment"'
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed'
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            emailext (
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                    <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext (
                subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                    <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
