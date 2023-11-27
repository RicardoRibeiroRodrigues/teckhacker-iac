
resource "aws_codepipeline" "ci_cd_pipeline" {
  name     = "django-ci-cd-pipeline"
  role_arn = aws_iam_role.django_cicd_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = aws_s3_bucket.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.repository_owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.repository_name
        OAuthToken             = var.github_token
      }

      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = aws_codebuild_project.django-ci-build.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "DeployStaging"

    action {
      category = "Deploy"
      configuration = {
        "ApplicationName"     = "get-it"
        "DeploymentGroupName" = "get-it"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name      = "DeployStaging"
      owner     = "AWS"
      provider  = "CodeDeploy"
      run_order = 1
      version   = "1"
    }

    action {
      category = "Approval"
      configuration = {
        "CustomData" = "Approve this version for Production"
      }
      name      = "ApproveDeployment"
      owner     = "AWS"
      provider  = "Manual"
      run_order = 3
      version   = "1"
    }
  }

  stage {
    name = "DeployProd"

    action {
      category = "Deploy"
      configuration = {
        "ApplicationName"     = "get-it"
        "DeploymentGroupName" = "get-it-prod"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name      = "DeployProd"
      owner     = "AWS"
      provider  = "CodeDeploy"
      run_order = 1
      version   = "1"
    }
  }

}