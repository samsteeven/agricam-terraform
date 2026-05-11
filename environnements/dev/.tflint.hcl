plugin "aws" {
  enabled = true
  version = "0.25.0"
  source = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Projet", "Environnement", "Propriétaire"]
}
