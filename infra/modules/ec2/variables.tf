variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "security_group_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type = string
}