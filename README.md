# Kickstart

- `user-data.sh` for cloud-init, currently only supports Amazon Linux 2 and CentOS 8
  - Use `bash -x` for a manual run
- Amazon Linux docker image isn't really the same with the actual instance and can't be used for testing
  - Use `run_ec2.sh` to to run an EC2 instance for testing
- Compatible with A1 instances
