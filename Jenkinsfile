pipeline {
    agent {
        docker {
            image 'zippadd/aws-serverless-node-docker:node12.13.0-r1'
            label 'awsNodeContainer'
            // args  '-v /tmp:/tmp'
        }
    }

    stages {
        stage('Test') {
            steps {
                npm test
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}