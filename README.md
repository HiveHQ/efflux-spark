# efflux-spark
This project serves as a single-source repository for everything needed to get a decent standalone cluster of Apache Spark running.

When combined with AWS, Apache Spark serves as a great tool for processing huge data sets. The biggest benefit in the newer versions of Hadoop is the S3A access method, for much faster and flexible reading from S3 buckets. That is not ready to use out of the box, so we try and get that going here for you.

## Quick start on EC2
Untar the spark archive and change into the `ec2` directory

Set your AWS IAM env variables:

`export AWS_ACCESS_KEY_ID=12345 AWS_SECRET_ACCESS_KEY=12345`

These are the options I generally use to ge things going, you can always check out `./spark-ec2 --help` for other options that might better suit what it is you need.

Note that to use S3A you need:
* `--hadoop-major-version 2`
* `--deploy-root-dir=/absolute/path/to/spark-tools` -- The additonal jar files in the `spark-tools` directory of this repo in order to use the S3A methods.

`./spark-ec2 -k KEY_PAIR_NAME -i PATH_TO_PEM -s NUM_SLAVES --hadoop-major-version=2 --deploy-root-dir=/abs/path/to/spark-tools launch CLUSTER_NAME`

Now, login to your master:
`./spark-ec2 -k KEY_PAIR_NAME -i PATH_TO_PEM login CLUSTER_NAME`

And create: `/root/spark/conf/spark.properties`

And add the following:
```
spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
```

Now, edit: `/root/spark/conf/spark-defaults.conf` and add the following lines:
```
spark.driver.extraClassPath /spark-tools/hadoop-aws-2.7.1.jar:/spark-tools/aws-java-sdk-1.7.4.jar
spark.executor.extraClassPath /spark-tools/hadoop-aws-2.7.1.jar:/spark-tools/aws-java-sdk-1.7.4.jar
```

You can store your credentials in ENV vars or by editing `/root/spark/conf/core-site.xml` and adding:
```
<property>
    <name>fs.s3a.access.key</name>
    <value>ACCESS_ID</value>
  </property>

  <property>
    <name>fs.s3a.secret.key</name>
    <value>SECRET_KEY</value>
  </property>
```

Finally, we have to move those jar files to all slaves, so from the `/root` directory:
`./spark-ec2/copy-dir.sh /spark-tools`



