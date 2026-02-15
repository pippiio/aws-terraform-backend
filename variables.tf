variable "name" {
  description = "Name of tfstate bucket"
  type        = string
  nullable    = false
}

variable "tfstate" {
  description = "A list of tfstates to create within bucket"
  type        = set(string)
  default     = []
  nullable    = false
}

variable "github_repositories" {
  description = "A set of GitHub repositories with OIDC read/wrtie access to tfstate"
  type        = set(string)
  default     = []
  nullable    = false
}
