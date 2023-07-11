variable "release_version" {
}

variable "region" {
  default = "ap-guangzhou"
}

variable "availability_zone" {
  default = "ap-guangzhou-3"
}

variable "instance_type" {
  default = "SA2.MEDIUM2"
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 5
}

variable "desired_capacity" {
  default = 1
}

variable "cvm_product" {
  default = "cvm"
}
