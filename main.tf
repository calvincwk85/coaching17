resource "aws_ecr_repository" "ecr" {
  name         = "${local.prefix}-ecr"
  force_delete = true
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.0"

  cluster_name = "${local.prefix}-ecs"
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
  services = {
    cal-coaching17-ecs-taskdef = { #task definition and service name -> #Change
      cpu    = 512
      memory = 1024
      container_definitions = {
        Cal-CONTAINER-NAME = { #container name -> Change
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-ecr:latest"
          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }
      assign_public_ip                   = true
      deployment_minimum_healthy_percent = 100
      subnet_ids                   = ["subnet-085e1089341f1aaa9", "subnet-0a9ad1569e0f18a9a", "subnet-03725ec4cbf6c1b85"] #List of subnet IDs to use for your tasks
      security_group_ids           = ["sg-077fcac0bc8879e6a"] #Create a SG resource and pass it here
    }
  }
}

