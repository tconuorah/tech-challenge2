pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
    AWS_ACCOUNT_ID     = '521037247172'
    ECR_REPO           = 'hello-app'
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
    CLUSTER_NAME       = 'tc2-eks'
    CHART_NAME         = 'hello-app'
    REGISTRY           = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

    // 🔧 SET THESE TO MATCH YOUR REPO LAYOUT
    // If your Dockerfile is at repo root, keep as 'Dockerfile' and BUILD_CONTEXT='.'
    DOCKERFILE         = 'app/Dockerfile'   // e.g. 'app/Dockerfile' or 'backend/Dockerfile'
    BUILD_CONTEXT      = 'app'            // e.g. 'app' or 'backend'
    HELM_CHART_PATH    = './helm-chart' // change if your chart lives elsewhere
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/tconuorah/tech-challenge2'
      }
    }

    stage('Preflight') {
      steps {
        sh 'bash -lc "set -euo pipefail; echo Repo tree (top level):; ls -la; echo; echo Looking for: \\"${DOCKERFILE}\\"; [ -f \\"${DOCKERFILE}\\" ] || { echo >&2 \\"ERROR: Dockerfile not found at ${DOCKERFILE}. Update DOCKERFILE/BUILD_CONTEXT in Jenkinsfile.\\"; exit 1; }"'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'bash -lc "set -euo pipefail; docker build -f \\"${DOCKERFILE}\\" -t \\"${ECR_REPO}:${IMAGE_TAG}\\" \\"${BUILD_CONTEXT}\\"; docker tag \\"${ECR_REPO}:${IMAGE_TAG}\\" \\"${REGISTRY}/${ECR_REPO}:${IMAGE_TAG}\\""'
      }
    }

    stage('Push to ECR') {
      steps {
        sh 'bash -lc "set -euo pipefail; aws ecr get-login-password --region \\"${AWS_DEFAULT_REGION}\\" | docker login --username AWS --password-stdin \\"${REGISTRY}\\"; docker push \\"${REGISTRY}/${ECR_REPO}:${IMAGE_TAG}\\""'
      }
    }

    stage('Deploy to EKS via Helm') {
      steps {
        sh 'bash -lc "set -euo pipefail; aws eks update-kubeconfig --name \\"${CLUSTER_NAME}\\" --region \\"${AWS_DEFAULT_REGION}\\"; helm upgrade --install \\"${CHART_NAME}\\" \\"${HELM_CHART_PATH}\\" --set image.repository=\\"${REGISTRY}/${ECR_REPO}\\" --set image.tag=\\"${IMAGE_TAG}\\" --set service.type=LoadBalancer --set service.port=80"'
      }
    }
  }

  post {
    always {
      // Only prune if Docker is accessible to this user
      sh 'bash -lc "(docker info >/dev/null 2>&1) && docker system prune -af || true"'
    }
  }
}
