###################################
## Virtual Machine Module - Main ##
###################################



# Create EC2 Instance
resource "aws_instance" "linux-server" {
  ami                         = "ami-06334a6e92bb3f864"
  instance_type               = var.linux_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.aws-linux-sg.id]
  associate_public_ip_address = var.linux_associate_public_ip_address
  source_dest_check           = false
  key_name                    = "postgres_id_rsa"
  user_data                   = file("script-init.sh")
  
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("postgres_id_rsa")
    host = "${self.public_ip}"
    }
  
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get update -y",
  #     "sudo apt-get upgrade -y",
  #     "sudo apt-get install nginx -y",
  #     "sudo systemctl start nginx"
  #   ]
  # }

  provisioner "file" {
    source      = "./script-init.sh"
    destination = "/tmp/script-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i '/^[^#]*PasswordAuthentication[[:space:]]no/c\\PasswordAuthentication yes' /etc/ssh/sshd_config",
      "sudo -i systemctl restart sshd",
      "echo 'ubuntu:ubuntu' | sudo chpasswd",
      "tr -d '\r' </tmp/script-init.sh >a.tmp",
      "mv a.tmp script-init.sh",
      "chmod +x ./script-init.sh",
      "sudo ./script-init.sh"
    ]
  }
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo test"
  #   ]
  # }
  tags = {
    Name        = "${lower(var.app_name)}"
    Environment = var.app_environment
  }
}

# Create Elastic IP for the EC2 instance
resource "aws_eip" "linux-eip" {
  instance = aws_instance.linux-server.id
  vpc  = true
  tags = {
    Name        = "${lower(var.app_name)}-eip"
    Environment = var.app_environment
  }
}

# Associate Elastic IP to Linux Server
# resource "aws_eip_association" "linux-eip-association" {
#   instance_id   = aws_instance.linux-server.id
#   allocation_id = aws_eip.linux-eip.id
# }

# Define the security group for the Linux server
resource "aws_security_group" "aws-linux-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-linux-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming Postgres connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}"
    Environment = var.app_environment
  }
}
