resource "aws_s3_bucket" "insecure_bucket" {
  bucket = var.bucket
  acl    = var.acl
}