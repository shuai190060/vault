# ------------------------------------------------------------------------
# iam policy attach for worker nodes
# ------------------------------------------------------------------------

resource "aws_iam_policy" "elasticsearch_log_policy" {
  name = "elasticsearch_log_policy"
  description = "policy to allow send logs to cloudwatch"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attach" {
  policy_arn = aws_iam_policy.elasticsearch_log_policy.arn
  role       = aws_iam_role.nodes.name

}


# ------------------------------------------------------------------------
# security group setting for es
# ------------------------------------------------------------------------

resource "aws_security_group" "es" {
    name = "${var.elasticsearch}-sg"
    description = "https ingress"
    vpc_id = aws_vpc.vpc_vault.id

    ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
        "0.0.0.0/0"
    ]
  }
  
}

# ------------------------------------------------------------------------
# elasticsearch domain
# ------------------------------------------------------------------------

resource "aws_elasticsearch_domain" "elasticsearch_vault" {
  domain_name = "elasticsearch-vault"
  elasticsearch_version = "7.10"
  cluster_config {
    instance_type = "t3.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_type  = "gp2"
    volume_size  = 10

  }

#   vpc_options {
#     subnet_ids = [
#         # aws_subnet.private_subnet[1].id,
#         aws_subnet.private_subnet[0].id
#     ]
#     # security_group_ids = [ aws_security_group.es.id ]
#   }

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": "87.183.161.175"}
            },
            "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_role.cloudwatch_to_opensearch_role.arn}"
        },
        "Action": [
          "es:ESHttpPost"
        ],
        "Resource": "*"
      }
    ]
}
POLICIES

}

output "elastic_url" {
  value = aws_elasticsearch_domain.elasticsearch_vault.endpoint
}

output "Kibana_EndPoint" {
  value = aws_elasticsearch_domain.elasticsearch_vault.kibana_endpoint
}



# ------------------------------------------------------------------------
# permission to grant cloudwatch log to send to elasticsearch
# ------------------------------------------------------------------------
resource "aws_iam_role" "cloudwatch_to_opensearch_role" {
  name = "cloudwatch-to-opensearch-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "cloudwatch_to_opensearch_policy" {
  name   = "cloudwatch-to-opensearch-policy"
  description = "IAM policy for CloudWatch Logs to send logs to OpenSearch"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "es:ESHttpPost"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "cloudwatch_to_opensearch_attachment" {
  role       = aws_iam_role.cloudwatch_to_opensearch_role.name
  policy_arn = aws_iam_policy.cloudwatch_to_opensearch_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attachment" {
    role = aws_iam_role.cloudwatch_to_opensearch_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  
}



# ------------------------------------------------------------------------
# log subscription filter
# ------------------------------------------------------------------------
# resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_to_elasticsearch" {
#   name            = "cloudwatch_to_elasticsearch"
#   role_arn        = aws_iam_role.cloudwatch_to_opensearch_role.arn
#   log_group_name  = "/aws/eks/fluentbit-cloudwatch/workload/logging"
#   filter_pattern  = "app"
#   destination_arn = aws_elasticsearch_domain.elasticsearch_vault.arn
#   distribution    = "Random"
# }