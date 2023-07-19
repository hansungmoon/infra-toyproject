
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
          "name": "AWS_ACCESS_KEY_ID",
          "value": "${var.ACCESS_KEY_ID}"
        },
        {
          "name": "AWS_SECRET_ACCESS_KEY",
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
  deployment_maximum_percent         = 10
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.public_sg.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.user_target_group.arn
    container_name   = "marketboro-task"
    container_port   = 3000
  }
}
