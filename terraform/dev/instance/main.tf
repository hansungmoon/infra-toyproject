##################### ECS ###########################
resource "aws_ecs_cluster" "marketboro_cluster" {
  name = "tf-marketboro_cluster"
}

resource "aws_ecs_task_definition" "marketboro_task" {
  family                   = "marketboro-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "marketboro-task",
      "image": "124842092977.dkr.ecr.ap-northeast-2.amazonaws.com/marketboro:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "cpu": 0,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "app-logstream",
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_user_service_log_group.name}"
        }
      },
      "environment": [
        {
          "name": "ACCESS_KEY_ID",
          "value": "${var.ACCESS_KEY_ID}"
        },
        {
          "name": "SECRET_KEY",
          "value": "${var.SECRET_KEY}"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 2048
  cpu                      = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_cloudwatch_log_group" "ecs_user_service_log_group" {
  name = "tf-ecs-service-loggroup"
}

resource "aws_ecs_service" "user_ecs_service" {
  name                               = "marketboro-sv"
  cluster                            = aws_ecs_cluster.marketboro_cluster.id
  task_definition                    = aws_ecs_task_definition.marketboro_task.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 600
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [data.terraform_remote_state.vpc.outputs.private_sg_id]
    subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.user_target_group.arn
    container_name   = "marketboro-task"
    container_port   = 3000
  }
}

##################### ALB ###########################
resource "aws_lb" "user_lb" {
  name               = "tf-marketboro-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.vpc.outputs.public_sg_id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
}

resource "aws_alb_target_group" "user_target_group" {
  name        = "tf-marketboro-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
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

##################### Role & Policy ###########################

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "tf-record-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy-2" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

##################### Route53 Record ###########################

resource "aws_route53_record" "alb_record" {
  zone_id = "/hostedzone/Z02158151WM4D9CRZLLRR"  # Route 53 호스팅 영역의 Zone ID로 대체해야 합니다.
  name    = "www.marketboro.click"  # 연결할 도메인 이름으로 대체해야 합니다.
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.user_lb.dns_name]  # ALB의 DNS 이름으로 대체해야 합니다.
}

##################### data ###########################

data "terraform_remote_state" "vpc" {
  backend = "local"  # Replace with your actual backend configuration if using remote state
  config = {
    path = "../vpc/terraform.tfstate"  # Replace with the correct path to the state file of main.tf No. 1
  }
}