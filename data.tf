data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "code_pipeline_policy" {
  statement {
    actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "cloudwatch:*",
      "sns:*",
      "sqs:*",
      "iam:PassRole"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = [
      "*",
    ]
    effect = "Allow"
  }

  version = "2012-10-17"
}


data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "codebuild.amazonaws.com",
      ]

      type = "Service"
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}


data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectACL",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.artifact-bucket}",
      "arn:aws:s3:::${local.artifact-bucket}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = [
      "*",
    ]
  }
}
