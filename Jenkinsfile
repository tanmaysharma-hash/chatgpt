pipeline {
    agent any

    environment {
        DOCKER_USER = 'iiamabhishek05'
    }

    stages {
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

        // stage('Security Scan - Trivy') {
        //     steps {
        //         sh '''
        //             trivy image $DOCKER_USER/mern-app-frontend:latest
        //             trivy image $DOCKER_USER/mern-app-backend:latest
        //         '''
        //     }
        // }

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
        stage('Docker Cleanup local images') {
            steps {
                sh '''
                    docker rmi $DOCKER_USER/mern-app-frontend:latest
                    docker rmi $DOCKER_USER/mern-app-frontend:v$BUILD_NUMBER
                    docker rmi $DOCKER_USER/mern-app-backend:latest
                    docker rmi $DOCKER_USER/mern-app-backend:v$BUILD_NUMBER
                '''
            }
        }


       // stage('Docker Compose Build') {
        //     steps {
        //         sh 'docker-compose up -d --build'
        //     }
        // }
    }

    post {
        always {
            cleanWs()
        }
        success {
        publishHTML([
            reportDir: 'security-reports/frontend',
            reportFiles: 'dependency-check-report.html',
            reportName: 'Frontend Dependency Report',
            allowMissing: false
        ])
        publishHTML([
            reportDir: 'security-reports/backend',
            reportFiles: 'dependency-check-report.html',
            reportName: 'Backend Dependency Report',
            allowMissing: false
        ])
    }
    }
}