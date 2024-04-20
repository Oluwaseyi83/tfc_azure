variable "address_space" {
  description = "provide vpc cidr_block here"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "location" {
  description = "provide location to deploy your resources"
  type        = string
  default     = "East US"
}

variable "address_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default =     ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24"]
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_A2"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  type        = string
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  type        = string
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  type        = string
  default     = "latest"
}
