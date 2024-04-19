resource "azurerm_resource_group" "Data_PipelineRG" {
  name     = "${var.ResourceGroup}"
  location = var.location
}

resource "azurerm_databricks_workspace" "databricks-test" {
  name                = var.WorkSpace
  resource_group_name = azurerm_resource_group.Data_PipelineRG.name
  location            = azurerm_resource_group.Data_PipelineRG.location
  sku                 = "standard"
  tags                = { Env = "Dev" }
}

resource "databricks_group" "Datascience_group" {
  display_name               = "Some Group"
  allow_cluster_create       = false
 
}

resource "databricks_user" "my_user" {
  user_name    = "ultracarevs@gmail.com"
  display_name = "DataScience User"

}

resource "databricks_group_member" "Datascience_member" {
  group_id  = databricks_group.Datascience_group.id
  member_id = databricks_user.my_user.id
}



resource "databricks_cluster" "clusterdemo" {
  cluster_name            = var.Cluster
  node_type_id            = var.node_type_id
  spark_version           = var.spark_version
  autotermination_minutes = var.cluster_autotermination_minutes
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  custom_tags = { Env = "Dev" }
}

resource "databricks_notebook" "mynotebook1" {
  content_base64 = base64encode("print('Hello Databricks')")
  path           = "/Workspace/Users/4c0e6b4e-c5a8-4adc-b9ed-10f93fe1d639/RetrieveBabyNames"
  language       = "PYTHON"
  // format = "SOURCE"
}

resource "databricks_notebook" "mynotebook2" {
  content_base64 = base64encode("print('Hello Databricks')")
  path           = "/Workspace/Users/4c0e6b4e-c5a8-4adc-b9ed-10f93fe1d639/FilterBabyNames"
  language       = "PYTHON"
  // format = "SOURCE"
}

resource "databricks_job" "mydatabricksjob" {
  name                = "mydatabricksjob"
  timeout_seconds     = 3600
  max_concurrent_runs = 1

  job_cluster {
    job_cluster_key = "j"
    new_cluster {
      num_workers   = 1
      spark_version = var.spark_version
      node_type_id  = var.node_type_id
    }
  }

  task {
    task_key = "RetrieveBabyNames"
    new_cluster {
      num_workers   = 1
      spark_version = var.spark_version
      node_type_id  = var.node_type_id
    }

    notebook_task {
      notebook_path = var.notebook_path_RetrieveBabyNames
    }
  }

  task {
    task_key = "FilterBabyNames"
    new_cluster {
      num_workers   = 1
      spark_version = var.spark_version
      node_type_id  = var.node_type_id
    }

    notebook_task {
      notebook_path = var.notebook_path_FilterBabyNames
    }

    depends_on {
      task_key = "RetrieveBabyNames"
    }
  }

  email_notifications {
    no_alert_for_skipped_runs = true
  }

  depends_on = [ databricks_cluster.clusterdemo ]
}

