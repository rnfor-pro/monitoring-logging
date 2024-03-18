data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "netflix_role" {
  name               = "eks-cluster-cloud"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "netflix-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.netflix_role.name
}

#get vpc data
data "aws_vpc" "netflix_sg" {
  default = true
}
#get public subnets for cluster
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.netflix_sg.id]
  }

   filter {
    name   = "availability-zone"
    values = ["eu-west-2a", "eu-west-2b", "eu-west-2c", "eu-west-2d"]
  }
}
#cluster provision
resource "aws_eks_cluster" "netflix_cluster" {
  name     = "NETFLIX_CLUSTER"
  role_arn = aws_iam_role.netflix_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.netflix-AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "netflix_role2" {
  name = "eks-node-group-cloud"

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

resource "aws_iam_role_policy_attachment" "netflix-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.netflix_role2.name
}

resource "aws_iam_role_policy_attachment" "netflix-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.netflix_role2.name
}

resource "aws_iam_role_policy_attachment" "netflix-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.netflix_role2.name
}

#create node group
resource "aws_eks_node_group" "netflix_nodes" {
  cluster_name    = aws_eks_cluster.netflix_cluster.name
  node_group_name = "Node-cloud"
  node_role_arn   = aws_iam_role.netflix_role2.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = ["t3.medium"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.netflix-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.netflix-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.netflix-AmazonEC2ContainerRegistryReadOnly,
  ]
}