resource "aws_acm_certificate" "cert_for_app" {
  domain_name       = "app.shuhai.de"
  validation_method = "DNS"

  tags = {
    Environment = "app-test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "cert_arn" {
  value = aws_acm_certificate.cert_for_app.arn
}


# -------------------------------------------------------------------------------
# permission for eks node to use the certificate
# -------------------------------------------------------------------------------

resource "aws_iam_policy" "acm_policy" {
  name        = "ACMPolicy"
  description = "IAM policy to allow EKS worker nodes to use ACM"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ACMPermissions",
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:ImportCertificate"
      ],
      "Resource": "${aws_acm_certificate.cert_for_app.arn}"
    }
  ]
}
EOF
  depends_on = [ aws_acm_certificate.cert_for_app ]

}

resource "aws_iam_role_policy_attachment" "acm_policy_attachment" {
  role       = aws_iam_role.nodes.name
  policy_arn = aws_iam_policy.acm_policy.arn
  depends_on = [ aws_acm_certificate.cert_for_app ]
}