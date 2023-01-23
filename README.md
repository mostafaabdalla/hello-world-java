Jenkins CI/CD pipeline for a simple java application.

Jenkins job to clone the code from the github repo and build it using Maven and then copy the artifacts to Ansible server which will build the image from this artifact and push it to docker hub.

Another Jenkins job (CD) to deploy the artifacts to tomcat server installed on EC2 instance.

Modified the Jenkins job (CD) to deploy to docker container from this image we built earlier.

Modified the same jenkins job (CD) to deploy to AWS EKS cluster.
