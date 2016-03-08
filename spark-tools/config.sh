#!/bin/sh
touch /root/spark/conf/spark.properties
echo "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" >> /root/spark/conf/spark.properties
echo "spark.driver.extraClassPath /spark-tools/hadoop-aws-2.7.1.jar:/spark-tools/aws-java-sdk-1.7.4.jar" >> /root/spark/conf/spark-defaults.conf
echo "spark.executor.extraClassPath /spark-tools/hadoop-aws-2.7.1.jar:/spark-tools/aws-java-sdk-1.7.4.jar" >> /root/spark/conf/spark-defaults.conf
/root/spark-ec2/copy-dir.sh /spark-tools
export PATH=/root/spark/bin:/root/spark/sbin:$PATH
