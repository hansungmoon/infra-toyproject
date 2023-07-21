resource "aws_lb" "user_lb" {
  name               = "tf-marketboro-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_alb_target_group" "user_target_group" {
  name        = "tf-marketboro-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "user_http" {
  load_balancer_arn = aws_lb.user_lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.user_target_group.id
    type             = "forward"
  }
}