pipeline {
  agent any

  parameters {
    string(name: 'AWS_ACCOUNT_ID', defaultValue: '480415625422', description: 'AWS Account ID')
    string(name: 'AWS_REGION',     defaultValue: 'us-east-2',    description: 'Region')
    string(name: 'ECR_REPO',       defaultValue: 'hello-app',    description: 'ECR repo name')
    string(name: 'CLUSTER_NAME',   defaultValue: 'tc2-eks',      description: 'EKS cluster name')
  }

  environment {
    ECR_REGISTRY = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com"
    IMAGE_TAG    = "${env.BUILD_NUMBER}"
    IMAGE_URI    = "${env.ECR_REGISTRY}/${params.ECR_REPO}:${env.IMAGE_TAG}"
    AWS_DEFAULT_REGION = "${params.AWS_REGION}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Login to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
  sh '''
    aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" \
      | docker login --username AWS --password-stdin "${ECR_REGISTRY}"
  '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
          sh '''
      DOCKERFILE=app/Dockerfile
      CONTEXT=app

      docker build -f "$DOCKERFILE" -t "${ECR_REPO}:${IMAGE_TAG}" "$CONTEXT"
      docker tag "${ECR_REPO}:${IMAGE_TAG}" "${IMAGE_URI}"
      docker push "${IMAGE_URI}"
    '''
      }
    }

   stage('Kubeconfig') {
  steps {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
      sh '''
        export AWS_REGION="${AWS_DEFAULT_REGION}"
        export KUBECONFIG="${WORKSPACE}/kubeconfig"
        aws sts get-caller-identity
        aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" --kubeconfig "$KUBECONFIG" --alias jenkins
        kubectl --kubeconfig "$KUBECONFIG" get nodes
      '''
    }
  }
}

stage('Deploy (kubectl)') {
  steps {
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
      sh '''
        export AWS_REGION="${AWS_DEFAULT_REGION}"     # needed because kubectl exec plugin calls aws
        export KUBECONFIG="${WORKSPACE}/kubeconfig"
        # kubectl/helm commands here, same as above
      '''
    }
  }
}

  post {
    always {
      sh 'docker logout "${ECR_REGISTRY}" || true'
    }
  }
}
