locals {
  instance_types = {
    small  = "t3.micro"
    medium = "t3.small"
    large  = "t3.medium"
  }
  disk_sizes = {
    small  = 10
    medium = 20
    large  = 40
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Ubuntu 24.04 LTS officielle (Canonical).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------------------------
# Réseau
# ---------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "projet-annuel-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "projet-annuel-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "projet-annuel-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "projet-annuel-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "vm" {
  name        = "projet-annuel-vm"
  description = "SSH entrant, tout sortant"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "projet-annuel-vm" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  security_group_id = aws_security_group.vm.id
  description       = "SSH"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.vm.id
  description       = "Tout le trafic sortant"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------
resource "aws_key_pair" "deployer" {
  key_name   = "projet-annuel-deployer"
  public_key = trimspace(var.ssh_public_key)
}

resource "aws_instance" "vm" {
  count = var.vm_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.instance_types[var.vm_size]
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.vm.id]
  key_name               = aws_key_pair.deployer.key_name

  metadata_options {
    http_tokens = "required" # IMDSv2 obligatoire
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = local.disk_sizes[var.vm_size]
    encrypted   = true
  }

  tags = {
    Name = format("%s-%02d", var.name_prefix, count.index + 1)
    Size = var.vm_size
  }
}
