# module "catalogue" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "${local.common_name_suffix}-catalogue"
#   use_name_prefix = false
#   description = "Security group for catalogue with custom ports open within VPC, egress all traffic"
#   vpc_id      = data.aws_ssm_parameter.vpc_id.value

# }


module "sg" {
    count = length(var.sg_names)
    source = "git::https://github.com/clouddevops98/terraform-aws-sg.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = var.sg_names[count.index]
    sg_description = "Created for ${var.sg_names[count.index]}"
    vpc_id = local.vpc_id
}

# resource "aws_security_group_rule" "frontend_frontend_alb" {
#   type = "ingress"
#   security_group_id = module.sg[9].sg_id
#   source_security_group_id = module.sg[11].sg_id
#   from_port         = 80
#   protocol       = "tcp"
#   to_port           = 80
# }
