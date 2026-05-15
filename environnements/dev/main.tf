# Infrastructure AgriCam - Environnement de développement
# CamTech Solutions - Douala, Cameroun

# --- Déclaration du fournisseur AWS ---
terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "agricam-terraform-s3"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    # dynamodb_table = "agricam-terraform-lock" # Décommenter après création de la table
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Data Source : Récupérer l'AMI Ubuntu 22.04 la plus récente ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID officiel de Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Ressource 1 : VPC (Réseau privé virtuel) ---
resource "aws_vpc" "agricam_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "agricam-vpc-${var.environnement}"
    Projet      = "AgriCam"
    Entreprise  = "CamTech Solutions"
    Environnement = var.environnement
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 2 : Sous-réseau public ---
resource "aws_subnet" "agricam_subnet" {
  vpc_id            = aws_vpc.agricam_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name          = "agricam-subnet-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 3 : Passerelle Internet ---
resource "aws_internet_gateway" "agricam_igw" {
  vpc_id = aws_vpc.agricam_vpc.id

  tags = {
    Name          = "agricam-igw-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 4 : Table de routage ---
resource "aws_route_table" "agricam_route_table" {
  vpc_id = aws_vpc.agricam_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.agricam_igw.id
  }

  tags = {
    Name          = "agricam-route-table-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 5 : Association de la table de routage au sous-réseau ---
resource "aws_route_table_association" "agricam_route_assoc" {
  subnet_id      = aws_subnet.agricam_subnet.id
  route_table_id = aws_route_table.agricam_route_table.id
}

# --- Ressource 6 : Groupe de sécurité (Pare-feu) ---
resource "aws_security_group" "agricam_sg" {
  name        = "agricam-sg-${var.environnement}"
  description = "Groupe de securite AgriCam - ${var.environnement}"
  vpc_id      = aws_vpc.agricam_vpc.id

  # Autoriser le trafic HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acces HTTP public"
  }

  # Autoriser SSH uniquement depuis ton IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_admin]
    description = "SSH admin uniquement"
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Tous les protocoles
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "agricam-sg-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 7 : Instance EC2 (Serveur) ---
resource "aws_instance" "agricam_serveur" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.type_instance
  subnet_id     = aws_subnet.agricam_subnet.id
  vpc_security_group_ids = [aws_security_group.agricam_sg.id]

  tags = {
    Name          = "agricam-serveur-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# --- Ressource 8 : Bucket S3 (Stockage) ---
resource "aws_s3_bucket" "agricam_stockage" {
  bucket = "agricam-${var.environnement}-stockage-camtech-${random_id.bucket_suffix.hex}"

  tags = {
    Name          = "agricam-stockage-${var.environnement}"
    Projet        = "AgriCam"
    Environnement = var.environnement
    Entreprise    = "CamTech Solutions"
    Propriétaire  = "CamTech Solutions"
  }
}

# Génère un suffixe aléatoire pour éviter les conflits de noms de bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bloque l'accès public au bucket S3
resource "aws_s3_bucket_public_access_block" "agricam_s3_pab" {
  bucket = aws_s3_bucket.agricam_stockage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
