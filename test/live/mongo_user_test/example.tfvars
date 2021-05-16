service_configuration = [
  {
    serviceName     = "possums-data-store"
    mongoCluster    = "animals-mongo"
    mongoDatabase   = "marsupials-dev"
    mongoCollection = ["possums"]
  },
  {
    serviceName     = "numbats-data-store"
    mongoCluster    = "animals-mongo"
    mongoDatabase   = "marsupials-dev"
    mongoCollection = ["numbats"]
  },
   {
    serviceName     = "marsupial-data-store"
    mongoCluster    = "animals-mongo"
    mongoDatabase   = "marsupials-prod"
    mongoCollection = ["numbats","possums"]
  },
]