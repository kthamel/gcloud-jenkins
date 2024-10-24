pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                dir ("gcloud-infrastructure"){
                    sh 'pwd'
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir ("gcloud-infrastructure"){
                    sh 'terraform plan'
                }
            }
        }

        stage('Request Approval') {
            steps {
                script {
                   timeout(time: 1, unit: 'HOURS') {
                        approvalStatus = input message: 'Are you sure? ', ok: 'Submit', parameters: [choice(choices: ['Approved', 'Rejected'], name: 'ApprovalStatus')], submitter: 'user1,user2', submitterParameter: 'approverID'
                   }
                }
                echo "Approval status: ${approvalStatus}"
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { approvalStatus["ApprovalStatus"] == 'Approved' }
            }
            steps {
                dir ("gcloud-infrastructure"){
                    sh 'terraform apply --auto-approve'
                }
            }
        }

        stage('Copy Keys'){
           steps {
                dir ("gcloud-infrastructure"){
                    sh 'cp -rv kthamel-key /tmp'
                }
            } 
        }
    }
}
