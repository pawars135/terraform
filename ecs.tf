data "aws_iam_role" "ecs_task_execution_role" {
    name="ecsTaskExecutionRole"
    }

resource "aws_ecs_task_definition" "hello_world"{
    family="hello-world"
    network_mode="awsvpc"
    requires_compatibilities=["FARGATE"]
    cpu=1024
    memory=2048
    execution_role_arn= "${data.aws_iam_role.ecs_task_execution_role.arn}"
    container_definitions=<<DEFINITION
    [
        {
            "image":"821318158909.dkr.ecr.us-east-1.amazonaws.com/sam-nginx",
            "cpu": 1024,
            "memory": 2048,
            "name": "hello-world-app",
            "networkMode": "awsvpc",
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ]
        }
    ]
DEFINITION
}
resource "aws_ecs_cluster" "main"{
    name= "hello-world-cluster"
}

resource "aws_ecs_service" "hello_world"{
    name="hello-world-service"
    cluster=aws_ecs_cluster.main.id
    task_definition=aws_ecs_task_definition.hello_world.arn
    desired_count=var.appcount
    launch_type= "FARGATE"
    network_configuration {
        security_groups=[aws_security_group.hello_world_task.id]
        subnets=aws_subnet.private.*.id
    }
    load_balancer {
        target_group_arn=aws_lb_target_group.hello_world.id
        container_name="hello-world-app"
        container_port=80
    }
   depends_on =[aws_lb_listener.hello_world]
   
}
