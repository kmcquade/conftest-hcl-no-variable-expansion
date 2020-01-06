resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "insecure-bucket"
  acl    = "public"
}