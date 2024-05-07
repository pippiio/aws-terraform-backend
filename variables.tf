variable "name" {
  type = string
}

variable "tfstate" {
  type    = set(string)
  default = []
}
