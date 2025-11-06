variable "project_name" {
    default = "roboshop"
}

variable "environment"{
    default = "dev"
}

variable "sg_names" {
    default = [
        # databases
        "mongodb", "redis", "mysql", "rabbitmq",
        # backend
        "catalogue", "user", "cart", "shipping", "payment",
        # frontend
        "frontend",
        # bastion
        "bastion",
        # frontend load balancer
        "frontend_lb",
        # Backend ALB
        "backend_alb"
    ]
}

variable "zone_id" {
  default = "Z0775499YCLL41QUIF01"
}

variable "domain_name" {
    default = "somayya.fun"
}