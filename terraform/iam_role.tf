
resource "aws_iam_role" "django_cicd_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
              "events.amazonaws.com",
              "states.amazonaws.com",
              "cloudformation.amazonaws.com",
              "codebuild.amazonaws.com",
              "codepipeline.amazonaws.com",
              "codedeploy.amazonaws.com",
              "ec2.amazonaws.com",
              "secretsmanager.amazonaws.com",
            ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "django-cicd-role-${var.env}"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "django_cicd_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.env})"
  name        = "django-cicd-policy-${var.env}"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action : [
            "iam:PassRole"
          ],
          Resource : "*",
          Effect : "Allow"
        },
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:*"
          ],
          "Resource" = [
            "arn:aws:s3:::*",
            "arn:aws:s3:::*"
          ]
        },
        {
          Effect = "Allow",
          Action = [
            "ec2:*",
          ],
          Resource = "arn:aws:ec2:*:*:*"
        },
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*"
        },

        {
          "Action" : [
            "codepipeline:StartPipelineExecution"
          ],
          "Resource" : "arn:aws:codepipeline:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "events:DeleteRule",
            "events:DescribeRule",
            "events:PutRule",
            "events:PutTargets",
            "events:RemoveTargets"
          ],
          "Resource" : [
            "arn:aws:events:*:*:rule/*"
          ],
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ],
          "Resource" : [
            "arn:aws:codebuild:*:*:project/*",
            "arn:aws:codebuild:*:*:build/*"
          ],
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            "secretsmanager:CreateSecret"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:*:*:secret:*",
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:CreateBucket",
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListAllMyBuckets",
            "s3:GetBucketCors",
            "s3:PutBucketCors"
          ],
          "Resource" : "*"
        },
        {
          "Action" : [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:Describe*",
            "ecr:GetAuthorizationToken",
            "ecr:GetDownloadUrlForLayer"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : "robomaker.amazonaws.com"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterfacePermission"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:network-interface/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:Subnet" : [
                "${aws_subnet.stage_subnet.id}",
                "${aws_subnet.app_subnet.id}"
              ]
            }
          }
        },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetDeploymentGroup",
        "codedeploy:CreateDeployment",
        "codedeploy:BatchGet*",
        "codedeploy:List*",
        "codedeploy:StopDeployment",
        "codedeploy:ContinueDeployment"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:Get*",
        "ec2:List*"
      ],
      "Resource": "*"
    }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "django_cicd_policy_attachment" {
  role       = aws_iam_role.django_cicd_role.name
  policy_arn = aws_iam_policy.django_cicd_policy.arn
}

resource "aws_iam_instance_profile" "Ec2_Role_Attachment" {
  name = "Ec2-role-attachment"
  role = aws_iam_role.ec2_to_s3_read_role.name
}

resource "aws_iam_role" "ec2_to_s3_read_role" {
  name = "django-ec2-to-s3-read-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3_Read_Policy" {
  policy_arn = aws_iam_policy.Web_server_s3_bucket_access_policy.arn
  role       = aws_iam_role.ec2_to_s3_read_role.name
}

resource "aws_iam_policy" "Web_server_s3_bucket_access_policy" {
  name        = "Web-server-s3-bucket-access-policy"
  description = "Allows read/write access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.artifacts_bucket.arn,
          "${aws_s3_bucket.artifacts_bucket.arn}/*"
        ]
      }
    ]
  })
}