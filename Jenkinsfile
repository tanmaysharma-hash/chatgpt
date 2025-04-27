pipeline {
    agent any

    environment {
        DOCKER_USER = 'iiamabhishek05'
        SCANNER_HOME = tool 'sonarqube'
    }

    stages {
        
        stage('Clean the Workspace') {
            steps {
                cleanWs()        
            }
        }

        stage('Clone Repository') {
            steps {
                git branch: 'master',
                url: 'https://github.com/iiamabhishek/mern-chat-app.git',
                credentialsId: 'github'
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend') {
                    steps {
                        dir('frontend') {
                            configFileProvider([configFile(fileId: 'frontend-env', targetLocation: '.env')]) {
                                sh 'docker build -t $DOCKER_USER/mern-app-frontend:latest .'
                            }
                        }
                    }
                }
                stage('Build Backend') {
                    steps {
                        dir('backend') {
                            configFileProvider([configFile(fileId: 'backend-env', targetLocation: '.env')]) {
                                sh 'docker build -t $DOCKER_USER/mern-app-backend:latest .'
                            }
                        }
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        // Frontend analysis
                        sh """
                            $SCANNER_HOME/bin/sonar-scanner \
                                -Dsonar.projectKey=mern-frontend \
                                -Dsonar.sources=./frontend \
                                -Dsonar.host.url=http://localhost:9000 \
                        """
                        
                        // Backend analysis
                        sh """
                            $SCANNER_HOME/bin/sonar-scanner \
                                -Dsonar.projectKey=mern-backend \
                                -Dsonar.sources=./backend \
                                -Dsonar.host.url=http://localhost:9000 \
                        """
                    }
                }
            }
        }

        stage('Quality Gate Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar'
                }
            }
        }

        stage('Security Scan - Trivy') {
            steps {
                script {
                    sh '''
                        mkdir -p trivy-reports

                        # Frontend scan
                        trivy image --format template --template "/opt/trivy-contrib/html.tpl" -o trivy-reports/frontend-trivy-report.html $DOCKER_USER/mern-app-frontend:latest

                        # Backend scan
                        trivy image --format template --template "/opt/trivy-contrib/html.tpl" -o trivy-reports/backend-trivy-report.html $DOCKER_USER/mern-app-backend:latest
                    '''

                    archiveArtifacts artifacts: 'trivy-reports/**/*.html', fingerprint: true
                }
            }
        }


        stage('Security Scan - OWASP') {
            steps {
                script {
                    def scans = [
                        [name: 'MERN Frontend', path: './frontend', output: 'security-reports/frontend'],
                        [name: 'MERN Backend',  path: './backend',  output: 'security-reports/backend']
                    ]
                    scans.each { scan ->
                        dependencyCheck additionalArguments: "--scan ${scan.path} --project \"${scan.name}\" --format HTML --out ${scan.output}", odcInstallation: 'd-check'
                    }
                }
                archiveArtifacts artifacts: 'security-reports/**/*.html', fingerprint: true
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker tag $DOCKER_USER/mern-app-frontend $DOCKER_USER/mern-app-frontend:v$BUILD_NUMBER
                        docker tag $DOCKER_USER/mern-app-backend $DOCKER_USER/mern-app-backend:v$BUILD_NUMBER
                        
                        docker push $DOCKER_USER/mern-app-frontend:latest
                        docker push $DOCKER_USER/mern-app-frontend:v$BUILD_NUMBER
                        docker push $DOCKER_USER/mern-app-backend:latest
                        docker push $DOCKER_USER/mern-app-backend:v$BUILD_NUMBER
                    '''
                }
            }
        }

       // stage('Docker Compose Build') {
        //     steps {
        //         sh 'docker-compose up -d --build'
        //     }
        // }
    }
    post {
        success {
            build job: 'Mern-App-CD', 
            wait: false,
            parameters: [
                string(name: 'PARENT_BUILD_NUMBER', value: "${env.BUILD_NUMBER}")
            ]
        }
    }
}