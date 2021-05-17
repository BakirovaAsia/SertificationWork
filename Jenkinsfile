pipeline {
    agent any
    tools {
        Terraform "terraform0153"
    }
    stages {
        stage ('Config aws') {
            steps {
                sh 'aws configure set aws_access_key_id '
                sh 'aws configure set aws_secret_access_key '
                sh 'aws configure set default.region us-east-2'
                sh 'aws configure set default.output json'

            }
        }
        stage ('Get source') {
            steps {
                git credentialsId: 'a26eb7f0-751d-412b-a7cf-7a7e4b1b61c2', url: 'https://github.com/BakirovaAsia/SertificationWork.git'
            }
        }
        stage ('Create aws instances') {
            steps {
                sh 'terraform init'
                sh 'terraform plan'
                //sh 'terraform apply'
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