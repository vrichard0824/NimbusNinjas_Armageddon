data "aws_availability_zones" "tokyo" {
  provider = aws.tokyo
  state = "available"
}

data "aws_availability_zones" "newyork" {
  provider = aws.newyork
  state = "available"
}

data "aws_availability_zones" "london" {
  provider = aws.london
  state = "available"
}

data "aws_availability_zones" "saopaulo" {
  provider = aws.saopaulo
  state = "available"
}

data "aws_availability_zones" "australia" {
  provider = aws.australia
  state = "available"
}

data "aws_availability_zones" "hongkong" {
  provider = aws.hongkong
  state = "available"
}

data "aws_availability_zones" "california" {
  provider = aws.california
  state = "available"
}