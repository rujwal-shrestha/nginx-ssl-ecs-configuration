
# Tomcat Service
module "ecs_tomcat_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.2"

  create                         = true # Determines whether resources will be created (affects all resources)
  name                           = local.other_hosts[0].service
  family                         = local.other_hosts[0].service #unique name for task defination
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
  autoscaling_max_capacity = 2
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
    (local.other_hosts[0].name) = {
      cpu                      = 512
      memory                   = 1024
      essential                = true
      image                    = local.other_hosts[0].image_url
      interactive              = true
      readonly_root_filesystem = false
      port_mappings = [
        {
          name          = local.other_hosts[0].name
          containerPort = local.other_hosts[0].port
          hostPort      = local.other_hosts[0].port
          protocol      = "tcp"
        }
      ]
      enable_cloudwatch_logging = true
      memory_reservation        = 100
    }
  }

  subnet_ids = data.terraform_remote_state.stager_resources.outputs.private_subnets

  load_balancer = {
    service = {
      target_group_arn = element(module.nlb.target_group_arns, 2)
      container_name   = local.other_hosts[0].name
      container_port   = local.other_hosts[0].port
    }
  }

  security_group_rules = {
    nlb_ingress_8080 = {
      type        = "ingress"
      from_port   = local.other_hosts[0].port
      to_port     = local.other_hosts[0].port
      protocol    = "tcp"
      description = "Tomcat Service Port"
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
