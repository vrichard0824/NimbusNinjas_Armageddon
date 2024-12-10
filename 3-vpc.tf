resource "aws_vpc" "tokyo_vpc" {
  provider   = aws.tokyo
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tokyo-vpc"
  }
}

resource "aws_subnet" "tokyo_subnet_az1" {
  provider                = aws.tokyo
  vpc_id                  = aws_vpc.tokyo_vpc.id
  cidr_block              = var.subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.tokyo.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "tokyo-az1-subnet"
  }
}

resource "aws_subnet" "tokyo_subnet_az2" {
  provider                = aws.tokyo
  vpc_id                  = aws_vpc.tokyo_vpc.id
  cidr_block              = var.subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.tokyo.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "tokyo-az2-subnet"
  }
}

# Private subnet for future syslog (Stage 2)
resource "aws_subnet" "tokyo_private_syslog" {
  provider                = aws.tokyo
  vpc_id                  = aws_vpc.tokyo_vpc.id
  cidr_block              = "10.110.11.0/24"
  availability_zone       = data.aws_availability_zones.tokyo.names[2]
  map_public_ip_on_launch = false

  tags = {
    Name = "tokyo-private-syslog-subnet"
  }
}

resource "aws_internet_gateway" "tokyo_igw" {
  provider = aws.tokyo
  vpc_id   = aws_vpc.tokyo_vpc.id

  tags = {
    Name = "tokyo-igw"
  }
}

resource "aws_route_table" "tokyo_public_rt" {
  provider = aws.tokyo
  vpc_id   = aws_vpc.tokyo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tokyo_igw.id
  }

  tags = {
    Name = "tokyo-public-rt"
  }
}
##route tables
resource "aws_route_table_association" "tokyo_rta_az1" {
  provider        = aws.tokyo
  subnet_id       = aws_subnet.tokyo_subnet_az1.id
  route_table_id  = aws_route_table.tokyo_public_rt.id
}

resource "aws_route_table_association" "tokyo_rta_az2" {
  provider        = aws.tokyo
  subnet_id       = aws_subnet.tokyo_subnet_az2.id
  route_table_id  = aws_route_table.tokyo_public_rt.id
}

resource "aws_security_group" "tokyo_web_sg" {
  provider    = aws.tokyo
  name        = "tokyo-web-sg"
  description = "Allow inbound HTTP only"
  vpc_id      = aws_vpc.tokyo_vpc.id
  

### security groups settings
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tokyo-web-sg"
  }
}

resource "aws_launch_template" "tokyo_lt" {
  provider     = aws.tokyo
  name_prefix  = "tokyo-lt"
  image_id     = var.ami_ids["tokyo"]
  instance_type= var.instance_type
  vpc_security_group_ids = [aws_security_group.tokyo_web_sg.id]

  user_data = base64encode("#!/bin/bash\nyum -y install httpd\nsystemctl start httpd\nsystemctl enable httpd\necho '<h1>MidTown Medical from Tokyo</h1>' > /var/www/html/index.html")
}
#ASG
resource "aws_autoscaling_group" "tokyo_asg" {
  provider               = aws.tokyo
  name                   = "tokyo-asg"
  max_size               = 2
  min_size               = 1
  desired_capacity       = 1
  vpc_zone_identifier    = [aws_subnet.tokyo_subnet_az1.id, aws_subnet.tokyo_subnet_az2.id]
  health_check_type      = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.tokyo_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "tokyo-asg-instance"
    propagate_at_launch = true
  }
}

# -------------------- NEW YORK SETUP -----------------------
resource "aws_vpc" "newyork_vpc" {
  provider   = aws.newyork
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "newyork-vpc"
  }
}

resource "aws_subnet" "newyork_subnet_az1" {
  provider                = aws.newyork
  vpc_id                  = aws_vpc.newyork_vpc.id
  cidr_block              = var.subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.newyork.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "newyork-az1-subnet"
  }
}

resource "aws_subnet" "newyork_subnet_az2" {
  provider                = aws.newyork
  vpc_id                  = aws_vpc.newyork_vpc.id
  cidr_block              = var.subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.newyork.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "newyork-az2-subnet"
  }
}

resource "aws_internet_gateway" "newyork_igw" {
  provider = aws.newyork
  vpc_id   = aws_vpc.newyork_vpc.id
  tags = {
    Name = "newyork-igw"
  }
}

resource "aws_route_table" "newyork_public_rt" {
  provider = aws.newyork
  vpc_id   = aws_vpc.newyork_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.newyork_igw.id
  }

  tags = {
    Name = "newyork-public-rt"
  }
}

resource "aws_route_table_association" "newyork_rta_az1" {
  provider        = aws.newyork
  subnet_id       = aws_subnet.newyork_subnet_az1.id
  route_table_id  = aws_route_table.newyork_public_rt.id
}

resource "aws_route_table_association" "newyork_rta_az2" {
  provider        = aws.newyork
  subnet_id       = aws_subnet.newyork_subnet_az2.id
  route_table_id  = aws_route_table.newyork_public_rt.id
}

resource "aws_security_group" "newyork_web_sg" {
  provider    = aws.newyork
  name        = "newyork-web-sg"
  description = "Allow inbound HTTP only"
  vpc_id      = aws_vpc.newyork_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "newyork-web-sg"
  }
}

resource "aws_launch_template" "newyork_lt" {
  provider     = aws.newyork
  name_prefix  = "newyork-lt"
  image_id     = var.ami_ids["newyork"]
  instance_type= var.instance_type
  vpc_security_group_ids = [aws_security_group.newyork_web_sg.id]

  user_data = base64encode("#!/bin/bash\nyum -y install httpd\nsystemctl start httpd\nsystemctl enable httpd\necho '<h1>MidTown Medical from New York</h1>' > /var/www/html/index.html")
}

resource "aws_autoscaling_group" "newyork_asg" {
  provider               = aws.newyork
  name                   = "newyork-asg"
  max_size               = 2
  min_size               = 1
  desired_capacity       = 1
  vpc_zone_identifier    = [aws_subnet.newyork_subnet_az1.id, aws_subnet.newyork_subnet_az2.id]
  health_check_type      = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.newyork_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "newyork-asg-instance"
    propagate_at_launch = true
  }
}
#london Setup

resource "aws_vpc" "london_vpc" {
  provider   = aws.london
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "london-vpc"
  }
}

resource "aws_subnet" "london_subnet_az1" {
  provider                = aws.london
  vpc_id                  = aws_vpc.london_vpc.id
  cidr_block              = var.subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.london.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "london-az1-subnet"
  }
}

resource "aws_subnet" "london_subnet_az2" {
  provider                = aws.london
  vpc_id                  = aws_vpc.london_vpc.id
  cidr_block              = var.subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.london.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "london-az2-subnet"
  }
}

resource "aws_internet_gateway" "london_igw" {
  provider = aws.london
  vpc_id   = aws_vpc.london_vpc.id

  tags = {
    Name = "london-igw"
  }
}

resource "aws_route_table" "london_public_rt" {
  provider = aws.london
  vpc_id   = aws_vpc.london_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.london_igw.id
  }

  tags = {
    Name = "london-public-rt"
  }
}
##route tables
resource "aws_route_table_association" "london_rta_az1" {
  provider        = aws.london
  subnet_id       = aws_subnet.london_subnet_az1.id
  route_table_id  = aws_route_table.london_public_rt.id
}

resource "aws_route_table_association" "london_rta_az2" {
  provider        = aws.london
  subnet_id       = aws_subnet.london_subnet_az2.id
  route_table_id  = aws_route_table.london_public_rt.id
}

resource "aws_security_group" "london_web_sg" {
  provider    = aws.london
  name        = "london-web-sg"
  description = "Allow inbound HTTP only"
  vpc_id      = aws_vpc.london_vpc.id
  

### security groups settings
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "london-web-sg"
  }
}

resource "aws_launch_template" "london_lt" {
  provider     = aws.london
  name_prefix  = "london-lt"
  image_id     = var.ami_ids["london"]
  instance_type= var.instance_type
  vpc_security_group_ids = [aws_security_group.london_web_sg.id]

  user_data = base64encode("#!/bin/bash\nyum -y install httpd\nsystemctl start httpd\nsystemctl enable httpd\necho '<h1>MidTown Medical from London</h1>' > /var/www/html/index.html")
}
#ASG
resource "aws_autoscaling_group" "london_asg" {
  provider               = aws.london
  name                   = "london-asg"
  max_size               = 2
  min_size               = 1
  desired_capacity       = 1
  vpc_zone_identifier    = [aws_subnet.london_subnet_az1.id, aws_subnet.london_subnet_az2.id]
  health_check_type      = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.london_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "london-asg-instance"
    propagate_at_launch = true
  }
}