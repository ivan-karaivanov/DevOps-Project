# Current role needed in order for Jenkins to be able to push to ECR. The current role has Admin access and it's attached to the EC2 instance at the bottom #


resource "aws_iam_role" "role" {
  name               = "${local.name}-role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

data "aws_iam_policy" "admin_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

## Attaching the policy to the role##
resource "aws_iam_role_policy_attachment" "admin-role-policy-attach" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.admin_access.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.role.name
}
 