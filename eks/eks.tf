# This policy is added today 10/08/2023

//https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
//create EKSViewResourcesPolicy
# resource "aws_iam_policy" "eks_view_resources_policy" {
#   name        = "EKSViewResourcesPolicy"
#   description = "Policy to allow a principal to view Kubernetes resources for all clusters in the account"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "eks:ListFargateProfiles",
#           "eks:DescribeNodegroup",
#           "eks:ListNodegroups",
#           "eks:ListUpdates",
#           "eks:AccessKubernetesApi",
#           "eks:ListAddons",
#           "eks:DescribeCluster",
#           "eks:DescribeAddonVersions",
#           "eks:ListClusters",
#           "eks:ListIdentityProviderConfigs",
#           "iam:ListRoles"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = "ssm:GetParameter"
#         #Resource = "arn:aws:iam::233260055645:user/terraformadmin"
#         Resource = "arn:aws:iam::233260055645:user/terraformadmin"
#       }
#     ]
#   })
# }


# //https://docs.aws.amazon.com/eks/latest/userguide/connector_IAM_role.html
# // create AmazonEKSConnectorAgentRole and AmazonEKSConnectorAgentPolicy
# # resource "aws_iam_role" "eks_connector_agent_role" {
# #   name = "AmazonEKSConnectorAgentRole"

# #   assume_role_policy = jsonencode({
# #     Version = "2012-10-17"
# #     Statement = [
# #       {
# #         Effect = "Allow"
# #         Principal = {
# #           Service = "ssm.amazonaws.com"
# #       }
# #       Action = "sts:AssumeRole"
# #       }
# #     ]   
  
# #   })
# # }


# //https://docs.aws.amazon.com/eks/latest/userguide/connector_IAM_role.html
# // create AmazonEKSConnectorAgentRole and AmazonEKSConnectorAgentPolicy
# resource "aws_iam_role" "eks_connector_agent_role" {
#   name = "AmazonEKSConnectorAgentRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ssm.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "eks_connector_agent_policy" {
#   name = "AmazonEKSConnectorAgentPolicy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "SsmControlChannel"
#         Effect = "Allow"
#         Action = [
#           "ssmmessages:CreateControlChannel"
#         ]
#         Resource = "arn:aws:eks:*:*:cluster/*"
#       },
#       {
#         Sid    = "ssmDataplaneOperations"
#         Effect = "Allow"
#         Action = [
#           "ssmmessages:CreateDataChannel",
#           "ssmmessages:OpenDataChannel",
#           "ssmmessages:OpenControlChannel"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_connector_agent_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_connector_agent_custom_policy_attachment" {
#   policy_arn = aws_iam_policy.eks_connector_agent_policy.arn
#   role       = aws_iam_role.eks_connector_agent_role.name
# }
#Existing before the above was added today
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "nodes-role" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes-role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes-role.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes-role.name
}
# resource "aws_eks_cluster" "eks-project" {
#   name     = var.cluster-name
#   role_arn = aws_iam_policy.eks_view_resources_policy.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-2a.id,
      aws_subnet.private-us-east-2b.id,
      aws_subnet.public-us-east-2a.id,
      aws_subnet.public-us-east-2b.id
    ]
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  #depends_on = [aws_iam_role_policy_attachment.cluster_role-AmazonEKSClusterPolicy]



resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.eks-project.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes-role.arn

  subnet_ids = [
    aws_subnet.private-us-east-2a.id,
    aws_subnet.private-us-east-2b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.small"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }


  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}