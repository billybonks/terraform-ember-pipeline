variable "pipeline_name" {
  description = "name of the hosted app"
  type = "string"
}


variable "github_token" {
  type = "string"
}

variable "github_repo" {
  type = "string"
}

variable "github_username" {
  type = "string"
}

variable "deployment_bucket" {
  description = "name of the bucket, where the app is hosted"
  type = "string"
}

locals {
  artifact-bucket = "${var.pipeline_name}-artifact-bucket"
}
