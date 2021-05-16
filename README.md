You can get the connection strings when you start a cluster?

You can probably store the usernames and passwords separately and then log in creating the connection string manually, rather than storing the connection string

There is something to be said about statefiles here too - use AWS S3, Azure Blob Storage or GCP storage backend and encrypt at rest. 

Getting local provisioner to work is a pain - passwords etc

### Testing
This is a chance to try terratest

This is also 