
resource "aws_route53_zone" "papa_von_ning" {
  name = "papavonning.com"
}

resource "aws_route53_record" "cname" {
  zone_id = aws_route53_zone.papa_von_ning.zone_id
  name    = "app"  
  type    = "CNAME"
  ttl     = 300  

  records = [
    "a3ef4f1f896dc4480903791b08b4607f-909434386.us-east-1.elb.amazonaws.com" 
  ]
}