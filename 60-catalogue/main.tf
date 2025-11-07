resource "aws_instance" "catalogue" {
    ami = local.ami_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [local.catalogue_sg_id]
    subnet_id = local.private_subnet_id
    
    tags = merge (
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-catalogue"
        }
    )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }

  # terraform copies this file to catalogue server
  provisioner "file" {
    source = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/catalogue.sh",
        # "sudo sh /tmp/catalogue.sh"
        "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state = "stopped"
  depends_on = [ terraform_data.catalogue ]
}




resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_name_suffix}-catalogue-ami"
  source_instance_id = aws_ec2_instance_state.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ]
  tags = merge (
      local.common_tags,
      {
          Name = "${local.common_name_suffix}-catalogue-ami" # roboshop-dev-mongodb
      }
  )
}

resource "aws_lb_target_group" "catalogue" {
  name     = "${local.common_name_suffix}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60


  health_check {
    healthy_threshold = 2
    interval = 19
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 2
  }
}

resource "aws_launch_template" "catalogue" {
  name = "${local.common_name_suffix}-catalogue"
  # image_id = "aws_ami_from_instance.catalogue.id"
 


  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"


  vpc_security_group_ids = [local.catalogue_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name_suffix}-catalogue"
      }
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name_suffix}-catalogue"
      }
    )
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }
}