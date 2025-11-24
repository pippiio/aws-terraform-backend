variable "config" {
  description = "manifest config"
  type = map(object({
    name   = string
    github = set(string)
    policy = set(string)
  }))
}

variable "github_oidc_thumbprints" {
  description = "A list of OIDC thumbprints for GitHub Actions. Default is the current GitHub Actions thumbprint."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}
