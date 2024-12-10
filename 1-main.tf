 provider "aws" {
  region     = "ap-northeast-1" # Tokyo
  alias      = "tokyo"
}

provider "aws" {
  region     = "us-east-1" # New York
  alias      = "newyork"
}

provider "aws" {
  region     = "eu-west-2" # London
  alias      = "london"
}

provider "aws" {
  region     = "sa-east-1" # Sao Paulo
  alias      = "saopaulo"
}

provider "aws" {
  region     = "ap-southeast-2" # Australia
  alias      = "australia"
}

provider "aws" {
  region     = "ap-east-1" # Hong Kong
  alias      = "hongkong"
}

provider "aws" {
  region     = "us-west-1" # California
  alias      = "california"
}
