# Variables pour l'infrastructure AgriCam

variable "aws_region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "eu-north-1"  # Stockholm (Suède) - Lieu actuel du bucket S3
}

variable "environnement" {
  description = "Nom de l'environnement (dev, staging, prod)"
  type        = string
}

variable "type_instance" {
  description = "Type d'instance EC2 (taille de la machine virtuelle)"
  type        = string
  default     = "t2.micro"  # Gratuite dans le Free Tier AWS
}



variable "ip_admin" {
  description = "Adresse IP de l'administrateur autorisé à se connecter en SSH (format CIDR : X.X.X.X/32)"
  type        = string
}
