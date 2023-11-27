
resource "aws_codebuild_project" "django-ci-build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "django-ci-build"
  queued_timeout = 480
  service_role   = aws_iam_role.django_cicd_role.arn
  # vpc_config {
  #   security_group_ids = [aws_security_group.testing_security_group.id]
  #   subnets            = [aws_subnet.stage_subnet.id]
  #   vpc_id             = aws_vpc.staging_vpc.id
  # }
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled    = false
    name                   = "django-build-${var.env}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    # image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "db_pass"
      type  = "PLAINTEXT"
      value = var.DB_TEST_PASS
    }

    environment_variable {
      name  = "db_user"
      type  = "PLAINTEXT"
      value = var.DB_TEST_USER
    }

    environment_variable {
      name  = "db_name"
      type  = "PLAINTEXT"
      value = var.DB_NAME
    }

    environment_variable {
      name = "DB_URL"
      type = "PLAINTEXT"
      value = "postgres://localhost/${var.DB_NAME}?user=${var.DB_TEST_USER}&password=${var.DB_TEST_PASS}"
      # value = "postgres://${aws_instance.db_test_server.private_ip}/${var.DB_NAME}?user=${var.DB_TEST_USER}&password=${var.DB_TEST_PASS}"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = file("specs/django-build.yml")
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}