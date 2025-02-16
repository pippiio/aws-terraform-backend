variable "backends" {
  description = <<-EOL
    A map of named backends:
      administrator_iam_role: Gets KMS key admin rights. Defaults to metadata.iam_administrator_arn
      access: Grants backend permissions
        iam_role: (Optional) Set of IAM roles w. backend permissions
          name: The name of the IAM role 
          write: Wheter to grant the role write permissions (apply, import, etc.)
        github: (Optional) Set of GitHub repositories, :
          organization: GitHub organization name.
          repository: GitHub repository subject to the access permission.
          branch: Git branch subject to the access permissions. Defaults to all branches.
          write: Wheter to grant the role write permissions (apply, import, etc.)
  EOL
  type = map(object({
    administrator_iam_role = optional(string, null)
    access = object({
      iam_role = optional(set(object({
        role_arn = string
        write    = bool
      })), [])
      github = optional(set(object({
        organization = string
        repository   = string
        branch       = optional(string, "*")
        write        = bool
      })), [])
    })
  }))
  nullable = false

  validation {
    condition = alltrue([
      for backend_name, backend in var.backends :
      backend.administrator_iam_role == null || can(regex("^arn:aws:iam::[0-9]{12}:role/", backend.administrator_iam_role))
    ])
    error_message = "administrator_iam_role must be a valid IAM role ARN or null."
  }

  validation {
    condition = alltrue(flatten([
      for backend_name, backend in var.backends : [
        for role in backend.access.iam_role : can(regex("^arn:aws:iam::[0-9]{12}:role/", role.role_arn))
      ]
    ]))
    error_message = "Each iam_role.role_arn must be a valid IAM role ARN."
  }

  validation {
    condition = alltrue(flatten([
      for backend_name, backend in var.backends : [
        for repo in backend.access.github : alltrue([
          can(regex("^[a-zA-Z0-9_.-]+$", repo.organization)),
          can(regex("^[a-zA-Z0-9_.-]+$", repo.repository))
        ])
      ]
    ]))
    error_message = "Each GitHub repository must have a valid organization and repository name."
  }
}
