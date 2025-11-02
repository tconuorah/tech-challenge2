pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-2'
    ECR_REPO = '022440376442.dkr.ecr.us-east-2.amazonaws.com/hello-app'
    CLUSTER_NAME = 'eks-cluster'
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t $ECR_REPO:latest ./app
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        withAWS(region: "$AWS_REGION", credentials: 'aws-creds') {
          sh '''
            aws ecr get-login-password --region $AWS_REGION | \
            docker login --username AWS --password-stdin $ECR_REPO
            docker push $ECR_REPO:latest
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withAWS(region: "$AWS_REGION", credentials: 'aws-creds') {
          sh '''
            aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
            helm upgrade --install hello-app ./helm/hello-app \
              --set image.repository=$ECR_REPO,image.tag=latest
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment successful!"
    }
    failure {
      echo "❌ Deployment failed!"
    }
  }
}