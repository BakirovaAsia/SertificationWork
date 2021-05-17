pipeline {
    agent {
    dockerfile {
        filename 'Dockerfile.agent'
        args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
   
    stages {
        stage ('Config aws') {
            steps {
                sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
                sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
                sh 'aws configure set default.region us-east-2'
                sh 'aws configure set default.output json'

            }
        }
        stage ('Get source') {
            steps {
                git credentialsId: 'GitHubCredits', url: 'https://github.com/BakirovaAsia/SertificationWork.git'
            }
        }
        stage ('Create aws instances') {
            steps {
                //sh 'terraform init'
                //sh 'terraform plan'
                //sh 'terraform apply'
                sh 'echo "Create aws instances"'
            }
        }
        stage ('Ansible') {
            steps {
                sh 'echo "ansible"'
            }
        }
        stage ('Deploy image') {
            steps {
                sh 'echo "deploy"'
            }
        }
    }
}