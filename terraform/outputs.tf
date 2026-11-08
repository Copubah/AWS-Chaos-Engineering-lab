# ==========================================
# NETWORK OUTPUTS
# ==========================================

output "vpc_id" {
  description = "ResilienceLab VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "availability_zones" {
  description = "Availability Zones"
  value       = aws_subnet.public[*].availability_zone
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}


# ==========================================
# SECURITY OUTPUTS
# ==========================================

output "alb_security_group_id" {
  description = "Application Load Balancer security group"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Application EC2 security group"
  value       = aws_security_group.app.id
}

output "ec2_iam_role_arn" {
  description = "EC2 IAM role ARN"
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}


# ==========================================
# APPLICATION LOAD BALANCER OUTPUTS
# ==========================================

output "application_load_balancer_dns" {
  description = "Public application load balancer DNS"
  value       = aws_lb.main.dns_name
}

output "application_load_balancer_url" {
  description = "ResilienceLab application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "target_group_arn" {
  description = "Application target group ARN"
  value       = aws_lb_target_group.app.arn
}


# ==========================================
# AUTO SCALING OUTPUTS
# ==========================================

output "autoscaling_group_name" {
  description = "Application Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "EC2 Launch Template ID"
  value       = aws_launch_template.app.id
}

output "ami_id" {
  description = "Selected Amazon Linux AMI"
  value       = data.aws_ami.amazon_linux.id
}


# ==========================================
# CLOUDWATCH OUTPUTS
# ==========================================

output "cloudwatch_dashboard_name" {
  description = "ResilienceLab CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cloudwatch_alarm_names" {
  description = "Configured CloudWatch alarms"
  value = [
    aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.alb_errors.alarm_name,
    aws_cloudwatch_metric_alarm.low_capacity.alarm_name
  ]
}


# ==========================================
# SNS NOTIFICATION OUTPUTS
# ==========================================

output "sns_alert_topic_arn" {
  description = "SNS notification topic ARN"
  value       = aws_sns_topic.alerts.arn
}

output "notification_email" {
  description = "Configured CloudWatch notification email"
  value       = var.notification_email
}


# ==========================================
# AWS FAULT INJECTION SERVICE OUTPUTS
# ==========================================

output "fis_role_arn" {
  description = "AWS Fault Injection Service IAM role"
  value       = aws_iam_role.fis.arn
}

output "fis_experiment_template_id" {
  description = "EC2 termination experiment template ID"
  value       = aws_fis_experiment_template.terminate_instance.id
}