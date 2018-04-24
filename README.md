Terraform AWS ElasticSearch domian
==================================

Create a ElasticSearch domain


Example:

```
module "search" {
  source  = "Aplyca/elasticsearch/aws"

  name    = "My ES cluster"
  vpc_id  = "vpc-bsasdsf"
  newbits  = 10
  netnum  = 16
  azs     = ["us-east1"]
  access_sg_ids = ["sg-rewr4sre"]
  access_cidrs = ["172.168.0.0/26"]
  storage = 25

  tags {
    App = "my App"
    Environment = "Prod"
  }
}
```
