variable nlb_name {
    type = string
}

variable internal {
    type = bool
}

variable vpc_name {
    type = string
}

variable subnet_a_name {
    type = string
}

variable subnet_b_name {
    type = string
}

variable cross_zone {
    type = bool
}

variable "tg_config" {
  type = map
}
variable "forwarding_config" {
}