# accessing-memorystore-from-cloud-run
Artifacts for the Medium article on accessing Memorystore from Cloud Run.

This repository holds sample artifacts illustrating the use of Google Cloud Run in conjunction with
Memorystore (managed Redis).  The contents include a source Node.js application that will invoke
Memorystore to store and retrieve a value.  A Dockerfile is present to allow us to create a container
that is then stored in the container repository.  A Cloud Run instance is created associated with
a Serverless VPC Access connector and a Memorystore instance.

The Makefile contains the following rules:

* create-memorystore - Create an instance of Memorystore.
* create-connnection - Create a Serverless VPC Access connector.
* build - Build the Docker container that will be deployed to Cloud Run.
* deploy - Deploy the container to Cloud Run.
* do-all - Perform all the preceding tasks.
