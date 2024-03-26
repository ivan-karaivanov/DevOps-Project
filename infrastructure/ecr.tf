resource "aws_ecr_repository" "ecr" {
  name                 = local.name
  image_tag_mutability = "IMMUTABLE"
}