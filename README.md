# Tech Challenge 2 🚀  

This project demonstrates deploying a simple Python Flask application on **AWS EKS** using **Docker, Terraform, Kubernetes, Helm, and Jenkins**.  

---

## 📌 Project Overview  

The project workflow:  

1. **Flask App** → A simple Python web app that prints `Hello, World!`.  
2. **Docker** → Containerize the app using a `Dockerfile`.  
3. **EKS + Terraform** → Provision an EKS cluster with Terraform, configure IAM roles (IRSA) for the AWS Load Balancer Controller.  
4. **Kubernetes** → Deploy the application using Kubernetes manifests (with autoscaling).  
5. **Helm** → Install and configure the AWS Load Balancer Controller.  
6. **ECR** → Push Docker images to an AWS Elastic Container Registry.  
7. **Jenkins** → Automate build, push, and deployment via a CI/CD pipeline.  

---

## 🐍 Flask Application  

- A simple Python Flask app that returns `Hello, World!`.  

---

## 🐳 Docker  

1. Create a `Dockerfile` to containerize the application.  
2. Build and run the container locally to verify functionality.  

---

## ☁️ Terraform  

1. Provision an **EKS cluster**.  
2. Create **IAM Role Service Account (IRSA)** for the ALB Controller.  
3. Apply Terraform configs from the repo:  
   👉 [Terraform Code](https://github.com/tconuorah/tech-challenge2/tree/main/terraform)  

---

## 📦 Kubernetes  

1. Create an **ECR repo** in AWS named `hello-app`.  
2. Push the Docker image to the repo.  
3. Write Kubernetes YAML files to deploy the app on EKS with **Horizontal Pod Autoscaling (HPA)**.  
4. Apply the YAML files:  

```bash
kubectl apply -f k8s/
```

5. Retrieve the **External IP** of the LoadBalancer service and access the app in your browser.  

---

## ⎈ Helm  

Install the AWS Load Balancer Controller:  

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=tc2-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-2 \
  --set vpcId=$(terraform -chdir=terraform output -raw vpc_id)
```

---

## ⚙️ Jenkins  

1. Install Jenkins in a Docker container on localhost.  
2. Mount the Docker socket so Jenkins can build/tag/push images.  

```bash
chmod 666 /var/run/docker.sock
```

3. Restart the container.  
4. Retrieve Jenkins admin password:  

```bash
docker logs jenkins
```

5. Install required tools inside the Jenkins container:  
   - Docker  
   - AWS CLI  
   - kubectl  
   - Helm  

6. Configure Jenkins credentials with AWS keys.  
7. Build a **Jenkins pipeline** to automate:  
   - Build Docker image  
   - Push to ECR  
   - Deploy to EKS via `kubectl` & `helm`  

---

## ✅ Expected Outcome  

- Flask app accessible via an external LoadBalancer DNS.  
- Jenkins pipeline builds, pushes, and deploys automatically.  
- Kubernetes scales pods when CPU/Memory > 50%.  

---

## 📝 Author  

**Terrence Onuorah**  
