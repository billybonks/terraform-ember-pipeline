provider "aws" {
  region = "us-east-1"
}
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.pipeline_name}-codepipeline-role"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_policy.json}"
}

resource "aws_iam_role_policy" "attach_codepipeline_policy" {
  name = "${var.pipeline_name}-codepipeline-policy"
  role = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.aws_iam_policy_document.code_pipeline_policy.json}"
}

resource "aws_iam_role" "codebuild_assume_role" {
  name = "${var.pipeline_name}-codebuild-role"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_role.json}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.pipeline_name}-codebuild-policy"
  role = "${aws_iam_role.codebuild_assume_role.id}"
  policy = "${data.aws_iam_policy_document.codebuild_policy.json}"
}

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket = "${local.artifact-bucket}"
  acl    = "private"
}

resource "aws_codebuild_project" "build_project" {
  name          = "${var.pipeline_name}-build"
  description   = "The CodeBuild project for ${var.pipeline_name}"
  service_role  = "${aws_iam_role.codebuild_assume_role.arn}"
  build_timeout = "60"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.pipeline_name}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.build_artifact_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration = {
        Owner                = "${var.github_username}"
        OAuthToken           = "${var.github_token}"
        Repo                 = "${var.github_repo}"
        Branch               = "master"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["code"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.build_project.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        BucketName: "${var.deployment_bucket}",
        Extract: "true",
      }
    }
  }
}
