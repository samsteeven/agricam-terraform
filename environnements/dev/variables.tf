# Variables pour l'infrastructure AgriCam

variable "aws_region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "us-east-1"  # Virginie du Nord (région offrant la meilleure compatibilité Free Tier)
}

variable "environnement" {
  description = "Nom de l'environnement (dev, staging, prod)"
  type        = string
}

variable "type_instance" {
  description = "Type d'instance EC2 (taille de la machine virtuelle)"
  type        = string
  default     = "t2.micro"  # Gratuite dans le Free Tier AWS (t2.micro en us-east-1)
}



variable "ip_admin" {
  description = "Adresse IP de l'administrateur autorisé à se connecter en SSH (format CIDR : X.X.X.X/32)"
  type        = string
}
