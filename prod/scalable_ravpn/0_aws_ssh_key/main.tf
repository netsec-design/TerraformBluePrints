provider "aws" {
  region = var.aws-region

}

resource "aws_key_pair" "aws_key" {
  key_name   = var.ssh-key-name
  public_key = var.ssh-key
}