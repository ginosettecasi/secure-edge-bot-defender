resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket" "website_bucket" {
  bucket        = "secure-edge-bucket-${random_id.id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
  bucket     = aws_s3_bucket.website_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "default" {
