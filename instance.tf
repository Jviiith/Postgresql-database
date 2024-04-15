# Create private key to access server (define key)
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# Pull out public key attributes from generated key (generate key)
resource "aws_key_pair" "server_key" {
  key_name   = "database-server-key"
  public_key = tls_private_key.key.public_key_openssh
}

# Save generated public key on local machine
resource "local_file" "setup_server_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "database-server-key.pem"
}

# EC2 (Linux) instance with Postgresql 11
resource "aws_instance" "postgresql_instance" {
  ami                         = "ami-051f8a213df8bc089"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  key_name                    = "database-server-key"
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "Postgresql-Server"
  }
}

# SSH Connection into Postgres Instance and connect to Postgresql database
resource "null_resource" "postgres_connection" {

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.key.private_key_pem
    host        = aws_instance.postgresql_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      // Install Postgres
      "sudo yum update -y",
      "sudo yum install -y postgresql15.x86_64 postgresql15-server",
      "sudo postgresql-setup --initdb",
      "sudo systemctl start postgresql",
      "sudo systemctl enable postgresql",

      // Make copy of file
      "sudo cp /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.bak",

      // Edit psql.conf file - Allow listerns to Postgresql
      "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/\" /var/lib/pgsql/data/postgresql.conf",

      // Edit pg_hba.conf file - Allow connections to Postgresql database
      "sudo sed -i '$ a host    all             all             0.0.0.0/0               trust' /var/lib/pgsql/data/pg_hba.conf",
      "sudo sed -i '$ a host    all             all             ::/0                    trust' /var/lib/pgsql/data/pg_hba.conf",

      // PSQL operations
      "sudo -u postgres psql -c \"ALTER USER postgres WITH PASSWORD '123';\"",
      "sudo -u postgres psql -c 'CREATE DATABASE animedb;'",


      // Restart Postgresql server
      "sudo systemctl restart postgresql",
    ]
  }
}
