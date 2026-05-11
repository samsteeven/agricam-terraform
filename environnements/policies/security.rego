mkdir -p ~/projets/agricam-infra/policies
cat > ~/projets/agricam-infra/policies/security.rego << 'EOF'
package terraform.aws.security

# Interdire SSH ouvert depuis Internet (0.0.0.0/0)
deny[msg] {
  resource := input.resource.aws_security_group[_]
  ingress := resource.ingress[_]
  ingress.from_port == 22
  ingress.cidr_blocks[_] == "0.0.0.0/0"
  msg := "ERREUR: SSH ouvert depuis Internet est interdit. Utilisez une IP spécifique."
}

# Exiger le chiffrement S3
deny[msg] {
  resource := input.resource.aws_s3_bucket[_]
  not resource.server_side_encryption_configuration
  msg := "ERREUR: Le bucket S3 doit avoir le chiffrement activé."
}
EOF
