variable "name" {
  description = "Name of tfstate bucket"
  type        = string
  nullable    = false
}

variable "tfstate" {
  description = "A list of tfstates to create within bucket"
  type        = set(string)
  default     = []
}
