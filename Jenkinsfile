pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
    AWS_ACCOUNT_ID     = '521037247172'
    ECR_REPO           = 'hello-app'
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
    CLUSTER_NAME       = 'tc2-eks'
    CHART_NAME         = 'hello-app'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/tconuorah/tech-challenge2'
      }
    }

    stage('Build Docker Image') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          docker build -t $env:ECR_REPO:$env:IMAGE_TAG .
          docker tag $env:ECR_REPO:$env:IMAGE_TAG `
            "$($env:AWS_ACCOUNT_ID).dkr.ecr.$($env:AWS_DEFAULT_REGION).amazonaws.com/$($env:ECR_REPO):$($env:IMAGE_TAG)"
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          $registry = "$($env:AWS_ACCOUNT_ID).dkr.ecr.$($env:AWS_DEFAULT_REGION).amazonaws.com"
          $password = aws ecr get-login-password --region $env:AWS_DEFAULT_REGION
          $password | docker login --username AWS --password-stdin $registry
          docker push "$registry/$($env:ECR_REPO):$($env:IMAGE_TAG)"
        '''
      }
    }

    stage('Deploy to EKS via Helm') {
      steps {
        powershell '''
          $ErrorActionPreference = "Stop"
          aws eks update-kubeconfig --name $env:CLUSTER_NAME --region $env:AWS_DEFAULT_REGION
          $registry = "$($env:AWS_ACCOUNT_ID).dkr.ecr.$($env:AWS_DEFAULT_REGION).amazonaws.com"
          helm upgrade --install $env:CHART_NAME ./helm-chart `
            --set "image.repository=$registry/$($env:ECR_REPO)" `
            --set "image.tag=$($env:IMAGE_TAG)" `
            --set "service.type=LoadBalancer" `
            --set "service.port=80"
        '''
      }
    }
  }

  post {
    always {
      powershell 'docker system prune -af; exit 0'
    }
  }
}
