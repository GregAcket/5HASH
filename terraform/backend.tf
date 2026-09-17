terraform {
  backend "s3" {
    bucket               = "5hash-bucket"
    key                  = "5hash/terraform.tfstate"
    workspace_key_prefix = "5hash/workspaces"
    region               = "eu-west-3"
    use_lockfile         = true
  }
}
