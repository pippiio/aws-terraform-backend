variable "metadata" {
  description = "JSON encoded metadata."
  type        = string
  nullable    = false

  validation {
    error_message = "Metadata is not a valid json string."
    condition     = var.metadata == null || can(jsondecode(var.metadata))
  }
}

locals {
  metadata = jsondecode(var.metadata)
}
