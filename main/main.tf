################################################################################
# Defines the resources to be created
################################################################################

# CLUSTER
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.2.2"

  cluster_name = local.cluster.name
  create       = true # Determines whether resources will be created (affects all resources)

  cluster_settings = {
    "name" : "containerInsights",
    "value" : "enabled"
  }

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.cluster.name}"
      }
    }
  }

  cloudwatch_log_group_retention_in_days = 90
  create_cloudwatch_log_group            = true
  default_capacity_provider_use_fargate  = true # Use Fargate as default capacity provider

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 10
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 0
      }
    }
  }
}

################################################################################
# Service
################################################################################

# Nginx Service
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.2"

  create                         = true # Determines whether resources will be created (affects all resources)
  name                           = local.service.name
  family                         = local.service.name #unique name for task defination
  cluster_arn                    = module.ecs_cluster.arn
  launch_type                    = "FARGATE"
  cpu                            = 1024
  memory                         = 2048
  create_iam_role                = true # ECS Service IAM Role: Allows Amazon ECS to make calls to your load balancer on your behalf.
  create_task_definition         = true
  create_security_group          = true
  create_tasks_iam_role          = true #ECS Task Role
  create_task_exec_iam_role      = true
  create_task_exec_policy        = true #This includes permissions included in AmazonECSTaskExecutionRolePolicy as well as access to secrets and SSM parameters
  enable_autoscaling             = true
  enable_execute_command         = true
  force_new_deployment           = false
  ignore_task_definition_changes = false
  assign_public_ip               = false
  network_mode                   = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  runtime_platform = {
    "cpu_architecture" : "X86_64",
    "operating_system_family" : "LINUX"
  }
  autoscaling_max_capacity = 10
  autoscaling_min_capacity = 1
  autoscaling_policies = {
    "cpu" : {
      "policy_type" : "TargetTrackingScaling",
      "target_tracking_scaling_policy_configuration" : {
        "predefined_metric_specification" : {
          "predefined_metric_type" : "ECSServiceAverageCPUUtilization"
        }
      }
    },
    "memory" : {
      "policy_type" : "TargetTrackingScaling",
      "target_tracking_scaling_policy_configuration" : {
        "predefined_metric_specification" : {
          "predefined_metric_type" : "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }

  # Container definition(s)
  container_definitions = {
    (local.container.name) = {
      cpu                      = 512
      memory                   = 1024
      essential                = true
      image                    = local.container.image_url
      interactive              = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = local.container.tls_name
          containerPort = local.container.tls_port
          hostPort      = local.container.tls_port
          protocol      = "tcp"
        },
        {
          name          = local.container.name
          containerPort = local.container.port
          hostPort      = local.container.port
          protocol      = "tcp"
        },
        {
          name          = local.container.test_name
          containerPort = local.container.test_port
          hostPort      = local.container.test_port
          protocol      = "tcp"
        }
      ]
      enable_cloudwatch_logging = true
      memory_reservation        = 100

      mount_points = [
        {
          sourceVolume  = local.efs.name
          containerPath = "/etc/nginx/efs-mount/server/"
          readOnly      = false
        }
      ]
    }
  }
  volume = {
    (local.efs.name) = {
      efs_volume_configuration = {
        file_system_id     = data.terraform_remote_state.stager_resources.outputs.efs_id
        root_directory     = "/efs"
        transit_encryption = "ENABLED"
        authorization_config = {
          access_point_id = data.terraform_remote_state.stager_resources.outputs.efs_access_point_id
          iam             = "ENABLED"
        }
      }
    }
  }

  subnet_ids = data.terraform_remote_state.stager_resources.outputs.private_subnets

  load_balancer = {
    service-tls = {
      target_group_arn = element(module.nlb.target_group_arns, 0)
      container_name   = local.container.name
      container_port   = local.container.tls_port
    },

    service = {
      target_group_arn = element(module.nlb.target_group_arns, 1)
      container_name   = local.container.name
      container_port   = local.container.port
    },

    service-test = {
      target_group_arn = element(module.nlb.target_group_arns, 3)
      container_name   = local.container.name
      container_port   = local.container.test_port
    }

  }

  security_group_rules = {
    nlb_ingress_80 = {
      type        = "ingress"
      from_port   = local.container.port
      to_port     = local.container.port
      protocol    = "tcp"
      description = "Nginx Service Port"
      cidr_blocks = [local.vpc_cidr]
    }
    nlb_ingress_443 = {
      type        = "ingress"
      from_port   = local.container.tls_port
      to_port     = local.container.tls_port
      protocol    = "tcp"
      description = "Nginx Service Port TLS"
      cidr_blocks = [local.vpc_cidr]
    }
    nlb_ingress_test = {
      type        = "ingress"
      from_port   = local.container.test_port
      to_port     = local.container.test_port
      protocol    = "tcp"
      description = "Nginx Service Port TLS"
      cidr_blocks = [local.vpc_cidr]
    }
    efs_ingress = {
      type        = "ingress"
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "EFS Port"
      cidr_blocks = [local.vpc_cidr]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

################################################################################
# Supporting Resources
################################################################################

# IAM policy for ECS Task Role
resource "aws_iam_role_policy" "task_definition_role-policy" {
  name = "${local.service.name}-task-definition-role-policy"
  role = module.ecs_service.tasks_iam_role_name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# IAM policy for ECS Task Execution Role
resource "aws_iam_role_policy" "task_exec_role-policy" {
  name = "${local.service.name}-task-exec-role-policy"
  role = module.ecs_service.task_exec_iam_role_name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
        ],
        "Resource" : "*"
      }
    ]
  })
}
