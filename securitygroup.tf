resource "aws_security_group" "load_balancer" {
    name= "alb-security-group"
    vpc_id= aws_vpc.default.id
    ingress {
        from_port= 80
        to_port=80
        protocol="tcp"
        cidr_blocks= ["0.0.0.0/0"]
    }

    egress {
        from_port=0
        to_port=0
        protocol= "-1"
        cidr_blocks= ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "hello_world_task" {
    name= "task-security-group"
    vpc_id= aws_vpc.default.id
    ingress {
        from_port= 80
        to_port=80
        protocol="tcp"
        cidr_blocks= ["0.0.0.0/0"]
    }

    egress {
        from_port=0
        to_port=0
        protocol= "-1"
        cidr_blocks= ["0.0.0.0/0"]
    }
}