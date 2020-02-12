pipeline {
    agent {
        docker {
            image 'zippadd/aws-serverless-node-docker:node12.13.0-r3'
            args '-u root'
        }
    }
    options {
        timeout(time: 1, unit: 'HOURS') 
    }
    stages {
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Package') {
            steps {
                sh 'npm run package'
                sh 'terraform plan'
            }
        }
        stage('Deploy') {
            when {
                branch 'master'
            }
            environment {
                AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
            }
            steps {
                echo 'Deploying.... jk'
            }
        }
    }
    post { 
        success { 
            echo 'Deployment complete.'
        }
        failure { 
            echo 'Deployment failed.'
        }
    }
}
