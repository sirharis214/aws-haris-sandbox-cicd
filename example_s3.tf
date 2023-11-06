module "example_bucket" {
  source       = "git::https://github.com/sirharis214/secure-s3-bucket?ref=v0.0.3"
  bucket_name  = "haris-example-bucket"

  project_tags = local.tags
}
