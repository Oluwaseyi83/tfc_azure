variable "ResourceGroup" {
  description = "Name of your Resource Group"
  type        = string
  default     = "Data_PipelineRG"
}

variable "location" {
  description = "Location of Resource"
  type        = string
  default     = "East US"
}

variable "WorkSpace" {
  description = "Name of the Workspace"
  type        = string
  default     = "MyWorkSpace"
}

variable "Cluster" {
  description = "A name for the cluster."
  type        = string
  default     = "MyCluster"
}

variable "spark_version" {
  description = "Spark Runtime Version for databricks clusters"
  type        = string
  default     = "7.3.x-scala2.12"
}

variable "node_type_id" {
  description = "Give the node type id here"
  type        = string
  default     = "Standard_DS3_v2"

}

variable "notebook_path_RetrieveBabyNames" {
  description = "Path to a notebook"
  default     = "/RetrieveBabyNames"
}

variable "notebook_path_FilterBabyNames" {
  description = "Path to a notebook"
  default     = "/FilterBabyNames"
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity."
  type        = number
  default     = 60
}

variable "notebook_filename" {
  description = "The notebook's filename."
  type        = string
  default = "notebook-getting-started-lakehouse-e2e.py"
}

variable "min_workers" {
  description = "Minimum number of worker clusters"
  default     = 1
}

variable "max_workers" {
  description = "Maximum numver of worker clusters"
  default     = 4
}

variable "cluster_num_workers" {
  description = "The number of workers."
  type        = number
  default     = 1
}

variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

