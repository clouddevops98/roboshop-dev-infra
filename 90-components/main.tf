# module "components" {
#   source = "../../terraform-roboshop-component"
#   component = var.component
#   rule_priority = var.rule_priority
# }

module "components" {
  source = "git::https://github.com/clouddevops98/terraform-roboshop-component.git?ref=main"
  component = eack.key
  rule_priority = ecah.value.rule_priority
}