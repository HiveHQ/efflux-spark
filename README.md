# efflux-spark
This project serves as a single-source repository for everything needed to get a decent standalone cluster of Apache Spark running.

When combined with AWS, Apache Spark serves as a great tool for processing huge data sets. The biggest benefit in the newer versions of Hadoop is the S3A access method, for much faster and flexible reading from S3 buckets. That is not ready to use out of the box, so we try and get that going here for you.

## Quick start on EC2
Download spark: http://www.apache.org/dyn/closer.lua/spark/spark-1.6.0/spark-1.6.0-bin-hadoop2.6.tgz

Untar the spark archive and change into the `ec2` directory.

You'll use the `spark-tools` directory in this repo to launch your cluster.

Set your AWS IAM env variables:

`export AWS_ACCESS_KEY_ID=12345 AWS_SECRET_ACCESS_KEY=12345`

These are the options I generally use to ge things going, you can always check out `./spark-ec2 --help` for other options that might better suit what it is you need.

Note that to use S3A you need:
* `--hadoop-major-version 2`
* `--deploy-root-dir=/absolute/path/to/spark-tools` -- The additonal jar files in the `spark-tools` directory of this repo in order to use the S3A methods.
* 
Some other options:
* If your app needs specific packages (i.e. Python modules) you may want to create your own AWS Linux AMI image with the packages pre-installed and use that. Otherwise you'll be in a world of ass-pain trying to get master and slaves configured the way you need. You can use the `-a AMI` option to make use of that custom AMI.

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

## Custom AMIs  

Needless to say, the spark AMI that the ec2 scripts use is old. At Efflux we're using Python for our preferred language to do analysis, so that means we want to use some additional libraries that are not installed.

We create our own AMI instance off of the base hvm AMI instance that the current ec2 scripts (as of 1.6) uses. You can fire up an EC2 instance of the current AMI by searching for the right AMI intance based off of the region you're running in.

https://github.com/amplab/spark-ec2/tree/branch-1.5/ami-list 

We use us-east-1 so, we build our image off of: ami-35b1885c

Some key things to note is that the ec2 scripts expect `root` to be enabled, newer AMI instances utilize `ec2-user`

After we launch the default AMI (takes a while to spin up b/c of updates) we upgrade Python and install additional Python packages:

```
yum install make automake gcc gcc-c++ kernel-devel git-core -y 

yum install python27-devel -y 
rm /usr/bin/python
ln -s /usr/bin/python2.7 /usr/bin/python 

cp /usr/bin/yum /usr/bin/_yum_before_27 
sed -i s/python/python2.6/g /usr/bin/yum 
sed -i s/python2.6/python2.6/g /usr/bin/yum 

python -V #should show you Python 2.7.X

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

pip install netaddr pymongo boto3 boto
```

