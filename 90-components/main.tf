module "components" {
  source = "../terraform-roboshop-component"
  component = var.component
  rule_priority = 10
}