pipeline {
  agent any

  parameters {
    string(name: 'AWS_ACCOUNT_ID', defaultValue: '480415625422', description: 'AWS Account ID')
    string(name: 'AWS_REGION',     defaultValue: 'us-east-2',    description: 'Region')
    string(name: 'ECR_REPO',       defaultValue: 'hello-app',    description: 'ECR repo name')
    string(name: 'CLUSTER_NAME',   defaultValue: 'tc2-eks',      description: 'EKS cluster name')
  }

  environment {
    ECR_REGISTRY      = "${params.AWS_ACCOUNT_ID}.dkr.ecr.${params.AWS_REGION}.amazonaws.com"
    AWS_DEFAULT_REGION= "${params.AWS_REGION}"
    IMAGE_TAG         = "${env.BUILD_NUMBER}"
    IMAGE_URI         = "${env.ECR_REGISTRY}/${params.ECR_REPO}:${env.IMAGE_TAG}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Login to ECR') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            set -e
            aws ecr describe-repositories --repository-names "${ECR_REPO}" >/dev/null 2>&1 || \
              aws ecr create-repository --repository-name "${ECR_REPO}"

            aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" \
              | docker login --username AWS --password-stdin "${ECR_REGISTRY}"
          '''
        }
      }
    }

    stage('Build & Push Image') {
      steps {
        dir('app') {
          sh '''
            set -e
            docker build -t "${ECR_REPO}:${IMAGE_TAG}" .
          '''
        }
        sh '''
          set -e
          docker tag "${ECR_REPO}:${IMAGE_TAG}" "${IMAGE_URI}"
          docker push "${IMAGE_URI}"
        '''
      }
    }

    stage('Kubeconfig') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            set -e
            export KUBECONFIG="${WORKSPACE}/kubeconfig"
            aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_DEFAULT_REGION}" --kubeconfig "$KUBECONFIG" --alias jenkins
            kubectl --kubeconfig "$KUBECONFIG" get nodes
          '''
        }
      }
    }

    stage('Deploy (kubectl)') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh '''
            set -e
            export KUBECONFIG="${WORKSPACE}/kubeconfig"
            # Apply manifests under k8s/
            kubectl --kubeconfig "$KUBECONFIG" apply -f k8s/
            # If your Deployment is named "hello" with container "hello":
            kubectl --kubeconfig "$KUBECONFIG" set image deployment/hello hello="${IMAGE_URI}" -n default || true
            kubectl --kubeconfig "$KUBECONFIG" rollout status deployment/hello -n default --timeout=120s || true
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout "${ECR_REGISTRY}" || true'
    }
  }
}
