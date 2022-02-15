
name := "Naive Bayes"

version := "1.0"

scalaVersion := "2.11.8"
val sparkVersion = "{{ SPARK_VERSION }}"

libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "2.7.0"
//libraryDependencies += "org.apache.spark" %% "spark-core"  % sparkVersion
//libraryDependencies += "org.apache.spark" %% "spark-mllib" % sparkVersion
libraryDependencies += "org.apache.spark" %% "spark-core"
libraryDependencies += "org.apache.spark" %% "spark-mllib"

// If using CDH, also add Cloudera repo
resolvers += "Cloudera Repository" at "https://repository.cloudera.com/artifactory/cloudera-repos/"

