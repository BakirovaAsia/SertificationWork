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
        DOCKERHUB_CREDS = credentials('DockerHubCreds')
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
                git credentialsId: 'GitHubCreds', url: 'https://github.com/BakirovaAsia/SertificationWork.git'
            }
        }
        stage ('Create aws instances') {
            steps {
                sh 'terraform init -input=false'
                sh 'terraform plan -out=tfplan -input=false'
                sh 'terraform apply -input=false tfplan'
            }
        }
        stage ('Build and deploy on aws instances') {
            environment {
                PUBLIC_IP_BUILD  = sh(script: 'terraform output -raw public_ip_build', , returnStdout: true).trim()
                PUBLIC_IP_DEPLOY = sh(script: 'terraform output -raw public_ip_deploy', , returnStdout: true).trim()
            }
            steps {
                sh 'whoami'
                sh 'export ANSIBLE_HOST_KEY_CHECKING=False'
                sh 'ansible-playbook ansible_roles.yml \
                        --extra-vars "build_vm_ip=$PUBLIC_IP_BUILD \
                                      deploy_vm_ip=$PUBLIC_IP_DEPLOY \
                                      DockerHub_user=$DOCKERHUB_CREDS_USR \
                                      DockerHub_pass=$DOCKERHUB_CREDS_PSW " -vvv'
            }
        }
    }
}