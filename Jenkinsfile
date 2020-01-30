pipeline {
    agent {
        docker {
            image 'zippadd/aws-serverless-node-docker:node12.13.0-r3'
            // label 'awsNodeContainer'
            args '-u root'
        }
    }

    stages {
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying.... jk'
            }
        }
    }
}
