

resource "aws_route53_zone" "main_zone" {
  count = var.dns_name == null ? 0 : 1
  name = var.dns_name

}