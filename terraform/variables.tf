variable "admin_password" {
  type        = string
  sensitive   = true
  description = "VM admin password (never commit a real value)"
}