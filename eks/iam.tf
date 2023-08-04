resource "aws_iam_role" "role" {
  name               = "eks-cluster-role"
  assume_role_policy = <<POLICY
  {
    "version": "2012-10-19",
    "statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "service": "eks.amazonaws.com"
        },
    "Action": "sts:AssumeRole"
    }
    ]
  }
    POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role.name
}
