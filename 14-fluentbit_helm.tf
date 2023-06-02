# ------------------------------------------------------------------------
# this is not working, because of lack of permission setup..?
# ------------------------------------------------------------------------
resource "helm_release" "fluent_bit" {
  name       = "my-fluent-bit"
  repository = "eks"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.24"  
  namespace = "logging"
  create_namespace = true

  
  values = [ "${file("aws-for-fluent-bit_values.yaml")}" ]
#   set {
#     name  = "elasticsearch.enabled"
#     value = "true"
#   }

#   set {
#     name  = "elasticsearch.host"
#     value = aws_elasticsearch_domain.elasticsearch_vault.endpoint
#   }

#   set {
#     name = "serviceAccount"
#     value = "fluent-bit"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.fluent_bit_role.arn
#   }

  depends_on = [ aws_elasticsearch_domain.elasticsearch_vault, aws_iam_role.fluent_bit_role ]
}


# ------------------------------------------------------------------------
# grant service account with permission to send logs to elastic search
# ------------------------------------------------------------------------

data "aws_iam_policy_document" "fluent-bit_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:logging:fluent-bit"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "fluent_bit_policy" {
  name        = "fluent-bit-policy"
  description = "Policy for Fluent Bit"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "es:*"
      ],
      "Resource": "${aws_elasticsearch_domain.elasticsearch_vault.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "fluent_bit_role" {
  assume_role_policy = data.aws_iam_policy_document.fluent-bit_assume_role_policy.json
  name               = "fluent_bit_role"
}

resource "aws_iam_role_policy_attachment" "fluent_bit_role_attach" {
  role       = aws_iam_role.fluent_bit_role.name
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
}


# ------------------------------------------------------------------------
# grant elasticsearch permission to node group
# ------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "elasticsearch_policy_attach" {
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
  role       = aws_iam_role.nodes.name
}


# ------------------------------------------------------------------------
# grant cloud watch permission to fluent-bit-service-account
# ------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_fluent-bit_attach" {
  policy_arn = aws_iam_policy.elasticsearch_log_policy.arn
  role       = aws_iam_role.fluent_bit_role.name

}