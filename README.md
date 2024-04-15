This is a single-tier AWS architecture use to host and deploy the latest version of Postgresql. Using terraform to provision the infrastructure. Code uses and creates following aws services:
VPC, Subnet, Route Table, Internet Gateway, Security Groups, EC2 Instance.

![Screenshot 2024-04-15 213312](https://github.com/Jviiith/Terraform/assets/107872597/47a6612f-a510-4fe5-8a22-1fe1ca9ba45e)

A Python application has been created to connect to a database and perform read, write, and update operations.

In order to to make the PostgreSQL instance resilient and highly available, I would need to create the instance in a private subnets using autoscaling groups, and deploy the instance in multiple availabilty zones.
