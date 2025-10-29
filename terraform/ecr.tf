resource "aws_ecr_repository" "hello_app" {
  name         = "hello-app"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true

  }

  encryption_configuration {
    encryption_type = "AES256" # change to "KMS" and add kms_key if you want CMK
    # kms_key       = aws_kms_key.ecr.arn
  }


  tags = {
    name = "prod"
  }
}

# Keep your repo tidy: expire untagged after 7d; keep last 50 tagged
resource "aws_ecr_lifecycle_policy" "hello_app" {
  repository = aws_ecr_repository.hello_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countNumber = 7
          countUnit   = "days"
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}

