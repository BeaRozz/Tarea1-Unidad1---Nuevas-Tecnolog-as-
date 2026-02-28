variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID para Amazon Linux 2 (ajustar según la región si es necesario)"
  type        = string
  default     = "ami-0c101f26f147fa7fd"
}

variable "project_name" {
  description = "Nombre del proyecto para tags y recursos"
  type        = string
  default     = "bearozz-tarea1"
}
