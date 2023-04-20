locals {
  # test values hardcoded here
  stack_name  = "stackname"
  environment = "environment"
  name_prefix = "${local.stack_name}-${local.environment}"
  aws_region  = "eu-west-2"

  container_port            = "8080"
  lb_listener_rule_priority = 100
  lb_listener_paths         = ["/*"]

  task_secrets = []
  task_environment = [
    { "name": "PORT", "value": "${local.container_port}" },
    { "name": "LOGLEVEL", "value": "debug" }
  ]

  service_name            = "servicename"
  docker_repo             = "dockerrepo"
  ecs_cluster_id          = "ecsclusterid"
  task_execution_role_arn = "arn:aws:iam::000000000000:role/taskexecutionrolearn"
  lb_listener_arn         = "arn:aws:elasticloadbalancing:eu-west-2:000000000000:listener/app/lblistenerarn/0000000000000000/0000000000000000"
  docker_registry         = "dockerregistry"
  container_version       = "containerversion"
}

provider "aws" {
  region  = local.aws_region
  version = "~> 4.54.0"
}

terraform {
  backend "s3" {
  }
}

# Get default VPC and subnets to keep test simple rather than using netowkrs remote state
data "aws_vpc" "default" {
  default = true
}

module "ecs-service" {
  source = "../" # up to root of repo

  # Environmental configuration
  environment             = local.environment
  aws_region              = local.aws_region
  vpc_id                  = "${data.aws_vpc.default.id}"
  ecs_cluster_id          = local.ecs_cluster_id
  task_execution_role_arn = local.task_execution_role_arn

  # Load balancer configuration
  lb_listener_arn           = local.lb_listener_arn
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = local.docker_registry
  docker_repo       = local.docker_repo
  container_version = local.container_version
  container_port    = local.container_port

  # Service configuration
  service_name = local.service_name
  name_prefix  = local.name_prefix

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets
}