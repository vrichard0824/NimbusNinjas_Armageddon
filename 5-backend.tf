terraform {
   backend "s3" {
       bucket = "mmcnimbusninjas"
       key = "s3key"
       region = "ap-northeast-1"
   }
}