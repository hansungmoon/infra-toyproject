resource "aws_route53_record" "alb_record" {
  zone_id = "/hostedzone/Z02158151WM4D9CRZLLRR"  # Route 53 호스팅 영역의 Zone ID로 대체해야 합니다.
  name    = "www.marketboro.click"  # 연결할 도메인 이름으로 대체해야 합니다.
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.user_lb.dns_name]  # ALB의 DNS 이름으로 대체해야 합니다.
}