
// example script to load data from hdfs

// import packages

import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import org.apache.spark.mllib.classification.NaiveBayes
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint

object bayes1 extends App
{
  // define variables

  // data file hdfs - example data
  //    Male,Suspicion of Alcohol,Weekday,12am-4am,75,30-39

  val hdfsServer = "hdfs://{{ HADOOP_NN_HOSTNAME }}"
  val dataFile = hdfsServer+ "{{ _APP_HDFS_IN_DIR }}" + "/" + "DigitalBreathTestData2013.csv"
  val appName = "Naive Bayes 1"
  val conf = new SparkConf()

  conf.setAppName(appName)

  // create the spark context

  val sparkCxt = new SparkContext(conf)

  // load raw csv data from hdfs 

  val csvData = sparkCxt.textFile(dataFile)

  // Now parse the CSV data into a LabeledPoint structure. Column zero of the column 
  // data becomes the label in the LabeledPoint i.e. Male/Female. The rest of the data 
  // columns become the features asociated with the label.

  val ArrayData = csvData.map
  {
    csvLine => 
      val colData = csvLine.split(',')
      LabeledPoint(colData(0).toDouble, Vectors.dense(colData(1).split(' ').map(_.toDouble)))
  }

  // divide the data ( randomly into training and testing data sets 

  val divData = ArrayData.randomSplit(Array(0.7, 0.3), seed = 13L)

  // get the train and test data 

  val trainDataSet = divData(0)
  val testDataSet  = divData(1)

  // train using Naive Bayes with the training data set

  val nbTrained = NaiveBayes.train(trainDataSet)
  
  // now run then trained model against the test data set

  val nbPredict = nbTrained.predict(testDataSet.map(_.features))

  // combine the prediction and test data 

  val predictionAndLabel = nbPredict.zip(testDataSet.map(_.label))

  // determine the accuracy

  val accuracy = 100.0 * predictionAndLabel.filter(x => x._1 == x._2).count() / testDataSet.count()

  // print the accuracy 

  println( "Accuracy : " + accuracy );

}
