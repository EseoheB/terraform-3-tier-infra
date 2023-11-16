terraform {
  backend "s3" {
    bucket = "mybucket-2793"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
    workspace_key_prefix = "env"
  }
}
