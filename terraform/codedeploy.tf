# Create a code deploy application
resource "aws_codedeploy_app" "get-it" {
  compute_platform = "Server"
  name             = "get-it"
}

# Create a code deploy deployment group
resource "aws_codedeploy_deployment_group" "get-it" {
  app_name               = aws_codedeploy_app.get-it.name
  deployment_group_name  = "get-it"
  service_role_arn       = aws_iam_role.django_cicd_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"


  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      value = aws_instance.test_server.tags.Name
      type  = "KEY_AND_VALUE"
    }
  }

}

# Production deployment group

resource "aws_codedeploy_deployment_group" "get-it-prod" {
  app_name               = aws_codedeploy_app.get-it.name
  deployment_group_name  = "get-it-prod"
  service_role_arn       = aws_iam_role.django_cicd_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      value = aws_instance.web_server.tags.Name
      type  = "KEY_AND_VALUE"
    }
  }
}