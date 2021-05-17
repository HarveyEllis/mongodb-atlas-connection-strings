# Connection strings for applications

This repo is part of a technical exercise performed for a job interview.

It consists of: 
- a module that can be used to create connection strings for a mongodb atlas cluster
- some test resources for testing the module using terratest, and a module for creating a test mongodb atlas cluster, which was heavily inspired by [this article](https://gmusumeci.medium.com/how-to-deploy-mongodb-atlas-on-gcp-using-terraform-3c88127c00d0)

## Requirements

To run the code in this repo you require: 
- terraform 0.14 or greater
- go installed (used go 1.16.4)
- [mongosh CLI](https://docs.mongodb.com/mongodb-shell/install/) (used in the tests to create test collections)
- a valid mongodb atlas organisation, the ability to create clusters, and access to an api key

## Running the code and tests
Setup the variables that are relevant to you in `private.tfvars`. These include the api keys for mongodb atlas, and the org id (for creating a new project for the cluster). The values must be added in both `./test/modules/mongodb_atlas_cluster/private.tfvars` and `./test/private.tfvars`. 

Then run: 
```
cd test
go get ./...
go test -v -timeout 30m
```

### Small bug with retries of the connection string
Sometimes the code doesn't run fully to completion. This is because there is a lag between the time the database users are created and then become available to be used. This means that on the odd occassion the tests will try and use the connection strings before they are ready and thus will fail. I have tried to remediate this by using `DoWithRetryableErrors` from the `terratest/retry` module, but something is not quite right with that funciton call.

Whilst obviously not ideal, rerunning the `go test` command will usually make the test pass a second time (it will start off from where it left of vis-a-vis terraform plans and applies)

## Testing
This was a chance for me to try [terratest](https://terratest.gruntwork.io/) (so I did!)

The testing of the project basically does the following:
- spins up a mongodb cluster
- uses a database admin account to login and create some databases and collections
- runs the connection string module
- tries to connect using the connection strings

The way that the testing is done is somewhat "dodgy", but in the circumstances (using and testing secrets) I think it is good enough. Essentially, we are using the fact that if you declare an output it gets stored in the statefile. Statefiles are also subject to change, so this method of testing might turn out to be brittle. 

## Security
It was required that for database passwords the "@![]()_" symbols were removed. This was simply because I found it to be simpler than escaping those characters everywhere. For example, this would be required if the connection string contains multiple @ (because the @ is semantically meaningful in connection strings). As a result, the passwords don't contain special characters. 

In terms of password strength, the length could be increased in the `random_password` resource. This would offset complexity decreases from removing special characters. 

Sensitive outputs are masked by marking every output or variable that contains sensitive informaiton with `sensitive = true`, however this is not enough to secure terraform in general - remote state that is encrypted by the cloud provider should be used.

The way that the connections are set up at the minute when they get tested is that they expose a public endpoint. In a more formal setting this would probably be tested using private connections from a VPC in a chosen cloud. 

## Overall philosopy of using a terraform module to create secrets for multiple applications
There is some argument to be had about whether you should create resources alongside the application that uses them, or in a single repo on the piece of infrastructure that is being provisioned. This module falls into the latter philosophy. On the one hand, having config for admin accounts in a single place means you can lock permissions to just those who need to deploy that repo, and have a central point of control. The downside is that if you are updating your app you then may have to go to multiple other repos to get your change made. 

This discussion becomes especially apt with kubernetes and if you are going to use a continuous delivery tool like argocd. In these cases it might be better to put the creation of the secrets with the app deployment manifests (and use the app of apps pattern), and use something like sealed secrets instead (where you can put the secret in git, encrypted). Terraform is a good way of creating infrastructure in this way, (certainly better than just using bash for creating and managing these kind of resources) and orcehstrating API calls, but if using kubernetes them something like [crossplane](https://crossplane.io/) might be better in the long run. 

## Potential improvements
In terms of testing the module could be improved by using a cloud provider secrets and stateful backend. This way the step of introspecting the statefile could be removed and replaced with something more secure.

At the current time, the collections and databases that get created in cluster creation are hard coded - this is obviously not ideal from a testing perspective, and we should be able to pass the names of those in, or use the go mongo db driver to create them rather than the terraform local provisioner. 

Finally, there is the small bug mentioned above - this could do with a bit more investigation, but I didn't have time. 