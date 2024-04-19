# Databricks notebook source
external_location = "<your_external_location>"
catalog = "<your_catalog>"

dbutils.fs.put(f"{external_location}/foobar.txt", "Hello world!", True)
display(dbutils.fs.head(f"{external_location}/foobar.txt"))
dbutils.fs.rm(f"{external_location}/foobar.txt")

display(spark.sql(f"SHOW SCHEMAS IN {catalog}"))

# COMMAND ----------

from pyspark.sql.functions import col

# Set parameters for isolation in workspace and reset demo
username = spark.sql("SELECT regexp_replace(current_user(), '[^a-zA-Z0-9]', '_')").first()[0]
database = f"{catalog}.e2e_lakehouse_{username}_db"
source = f"{external_location}/e2e-lakehouse-source"
table = f"{database}.target_table"
checkpoint_path = f"{external_location}/_checkpoint/e2e-lakehouse-demo"

spark.sql(f"SET c.username='{username}'")
spark.sql(f"SET c.database={database}")
spark.sql(f"SET c.source='{source}'")

spark.sql("DROP DATABASE IF EXISTS ${c.database} CASCADE")
spark.sql("CREATE DATABASE ${c.database}")
spark.sql("USE ${c.database}")

# Clear out data from previous demo execution
dbutils.fs.rm(source, True)
dbutils.fs.rm(checkpoint_path, True)

# Define a class to load batches of data to source
class LoadData:

  def __init__(self, source):
    self.source = source

  def get_date(self):
    try:
      df = spark.read.format("json").load(source)
    except:
        return "2016-01-01"
    batch_date = df.selectExpr("max(distinct(date(tpep_pickup_datetime))) + 1 day").first()[0]
    if batch_date.month == 3:
      raise Exception("Source data exhausted")
      return batch_date

  def get_batch(self, batch_date):
    return (
      spark.table("samples.nyctaxi.trips")
        .filter(col("tpep_pickup_datetime").cast("date") == batch_date)
    )

  def write_batch(self, batch):
    batch.write.format("json").mode("append").save(self.source)

  def land_batch(self):
    batch_date = self.get_date()
    batch = self.get_batch(batch_date)
    self.write_batch(batch)

RawData = LoadData(source)

# COMMAND ----------

RawData.land_batch()

# COMMAND ----------

# Import functions
from pyspark.sql.functions import col, current_timestamp

# Configure Auto Loader to ingest JSON data to a Delta table
(spark.readStream
  .format("cloudFiles")
  .option("cloudFiles.format", "json")
  .option("cloudFiles.schemaLocation", checkpoint_path)
  .load(file_path)
  .select("*", col("_metadata.file_path").alias("source_file"), current_timestamp().alias("processing_time"))
  .writeStream
  .option("checkpointLocation", checkpoint_path)
  .trigger(availableNow=True)
  .option("mergeSchema", "true")
  .toTable(table))

# COMMAND ----------

df = spark.read.table(table_name)

# COMMAND ----------

display(df)