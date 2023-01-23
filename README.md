
# Jenkins CI/CD pipeline for a smiple java application

Simple CI/CD pipeline to deploy the app on AWS K8s cluster.

First task:

    1. Having a CI job to clone the code from the github repo and build it using Maven.
    2. Deploy it to tomcat server installed on EC2 instance.

Second task:

    1. Copy the artifacts to Ansible server which will build the image from this artifact and push it to docker hub.
    2. Deploy to tomcat docker container using this image.

Third task:

    Deploy to AWS EKS cluster.


## So the final flow should be like this:

![App Screenshot](simple_CI_CD)

