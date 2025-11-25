variable "name" {
  type = string
}

variable "tfstate" {
  type    = set(string)
  default = []
}

variable "github_repos" {
  description = "List of GitHub repositories that will be granted access to the Terraform state."
  type        = set(string)
  default     = []
}

variable "profile" {
  description = "temp"
  type        = string
  default     = "default"
}
