# AWS Resilience Lab

An AWS Chaos Engineering and Resilience Testing platform built with Terraform, Python, and AWS Fault Injection Service (FIS).

The project provisions a fault-tolerant application environment and provides controlled infrastructure failure experiments to evaluate system availability, automated recovery, monitoring, and resilience.

## Project Overview

AWS Resilience Lab simulates infrastructure failures in an AWS environment and measures how effectively the system detects and recovers from them.

The initial experiment focuses on terminating an EC2 instance and observing how the Auto Scaling Group replaces it while the Application Load Balancer continues routing traffic to healthy instances.

## Architecture

The infrastructure is deployed in AWS `us-east-1`.

### AWS Services

| Service | Purpose |
|---|---|
| Amazon VPC | Isolated network environment |
| Public Subnets | Host application infrastructure across two Availability Zones |
| Internet Gateway | Internet connectivity |
| Application Load Balancer | Distributes incoming HTTP traffic |
| Amazon EC2 | Runs the Flask application |
| Auto Scaling Group | Maintains application capacity and replaces failed instances |
| Launch Template | Defines EC2 instance configuration |
| AWS Systems Manager | Enables instance management without SSH |
| AWS IAM | Controls service permissions |
| AWS Fault Injection Service | Executes controlled infrastructure failure experiments |
| Amazon CloudWatch | Monitors infrastructure health and performance |
| CloudWatch Alarms | Detects unhealthy targets, ALB errors, and low capacity |
| CloudWatch Dashboard | Provides operational visibility |
| Amazon SNS | Delivers monitoring notifications |

### Architecture Flow

```text
                    Internet
                       |
                       v
             Application Load Balancer
                       |
              Target Group :5000
                 /           \
                v             v
          EC2 Instance 1   EC2 Instance 2
                |             |
                +------+------+
                       |
                Flask Application
                       |
                 Health Endpoint

       Auto Scaling Group maintains capacity
                       |
              AWS Fault Injection
                       |
             Controlled EC2 Failure

       CloudWatch monitors infrastructure
                       |
                 SNS Notifications
```

## Key Features

- Infrastructure provisioning using Terraform.
- Multi-AZ deployment across two Availability Zones.
- Application Load Balancer with health checks.
- EC2 Auto Scaling with configurable minimum and maximum capacity.
- Python Flask application with health-check endpoints.
- AWS Systems Manager access without SSH.
- Controlled EC2 termination using AWS Fault Injection Service.
- CloudWatch monitoring and operational dashboards.
- Automated alerts through Amazon SNS.
- Recovery measurement and experiment reporting.

## Repository Structure

```text
aws-resilience-lab/
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── network.tf
│   ├── security.tf
│   ├── compute.tf
│   ├── alb.tf
│   ├── autoscaling.tf
│   ├── monitoring.tf
│   ├── iam.tf
│   ├── fis.tf
│   └── outputs.tf
│
├── application/
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── user_data.sh
│
├── chaos-experiments/
│   ├── terminate-instance.sh
│   ├── cpu-stress.sh
│   └── application-crash.sh
│
├── monitoring/
│   └── dashboard.json
│
├── reports/
│   └── experiment-results.md
│
├── .gitignore
└── README.md
```

Some experiment scripts and report files are planned components and should be added as they are implemented.

## Application

The application is built using Python and Flask.

### Available Endpoints

| Endpoint | Description |
|---|---|
| `/` | Returns application status, hostname, and timestamp |
| `/health` | Returns application health status |
| `/failure` | Simulates an HTTP 500 application failure |
| `/metrics` | Returns basic application information |

The application runs using Gunicorn and listens on port `5000`.

## Infrastructure Configuration

Default Terraform configuration:

| Parameter | Value |
|---|---|
| AWS Region | `us-east-1` |
| VPC CIDR | `10.0.0.0/16` |
| Public Subnets | `10.0.1.0/24`, `10.0.2.0/24` |
| EC2 Instance Type | `t3.micro` |
| Desired EC2 Capacity | 2 |
| Minimum EC2 Capacity | 2 |
| Maximum EC2 Capacity | 4 |
| Application Port | 5000 |
| Load Balancer Port | 80 |

The ALB security group restricts inbound access using the configured `allowed_cidr`. The application security group accepts traffic on port `5000` only from the ALB security group.

SSH access is not enabled. Systems Manager is used for instance administration.

## Prerequisites

Install and configure:

- AWS CLI
- Terraform 1.5 or later
- Python 3
- Git
- An AWS account with permissions to provision the required services
- AWS credentials configured through an appropriate AWS authentication method

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

Verify Terraform:

```bash
terraform version
```

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/Copubah/aws-resilience-lab.git
cd aws-resilience-lab/terraform
```

### 2. Configure Terraform variables

Create `terraform.tfvars`:

```hcl
notification_email = "your-email@example.com"
allowed_cidr       = "YOUR_PUBLIC_IP/32"
```

Replace the example email and IP address with your own values.

To retrieve your public IP:

```bash
curl -4 https://checkip.amazonaws.com
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format and validate

```bash
terraform fmt -recursive
terraform validate
```

### 5. Review the deployment plan

```bash
terraform plan -out=tfplan
```

Review the resources, estimated costs, and any destructive changes before proceeding.

### 6. Deploy infrastructure

```bash
terraform apply tfplan
```

### 7. Retrieve deployment outputs

```bash
terraform output
```

The outputs include infrastructure identifiers, the ALB endpoint, monitoring resources, and the FIS experiment template ID.

## Monitoring

The CloudWatch dashboard is named:

`aws-resilience-lab-dashboard`

It contains four monitoring widgets:

1. Application Load Balancer request count.
2. Unhealthy application targets.
3. Load Balancer HTTP 5XX errors.
4. Auto Scaling Group in-service instances.

### CloudWatch Alarms

| Alarm | Purpose |
|---|---|
| `aws-resilience-lab-alb-errors` | Detects elevated ALB HTTP 5XX errors |
| `aws-resilience-lab-low-capacity` | Detects capacity below the configured minimum |
| `aws-resilience-lab-unhealthy-hosts` | Detects unhealthy application targets |

### SNS Notifications

CloudWatch alarms publish notifications to the SNS topic:

`aws-resilience-lab-alerts`

An email subscription is configured through Terraform. The recipient must confirm the SNS subscription before receiving notifications.

## Chaos Engineering Experiments

The primary experiment uses AWS Fault Injection Service to terminate one EC2 instance selected through the project resource tag.

### Experiment Objective

Evaluate whether the Auto Scaling Group can detect and replace a terminated instance while the remaining application capacity continues serving requests.

### Planned Experiment Sequence

1. Record the healthy infrastructure baseline.
2. Confirm both EC2 instances are healthy and in service.
3. Confirm both ALB targets are healthy.
4. Start the FIS termination experiment.
5. Observe instance termination.
6. Monitor Auto Scaling replacement activity.
7. Confirm the replacement instance registers with the target group.
8. Verify application health.
9. Record recovery time and monitoring behaviour.

### Recovery Metrics

| Metric | Description |
|---|---|
| Detection Time | Time between failure and detection |
| Replacement Time | Time taken to launch a replacement instance |
| Registration Time | Time taken for the replacement to become a healthy ALB target |
| Recovery Time | Time until the system returns to its defined healthy baseline |
| MTTR | Mean Time to Recovery across repeated experiments |

The experiment must only be executed after reviewing its target selection, IAM permissions, and CloudWatch stop condition.

## Security Considerations

- Use IAM roles with least-privilege permissions.
- Avoid storing AWS access keys in the repository.
- Do not commit `terraform.tfvars`, Terraform state files, or private keys.
- Restrict ALB ingress to trusted IP addresses where practical.
- Keep application port `5000` accessible only through the ALB security group.
- Use AWS Systems Manager instead of opening SSH access.
- Review FIS experiment targets before execution.
- Monitor AWS costs and terminate unused resources.

## Cost Considerations

This project provisions chargeable AWS resources, including:

- EC2 instances and associated storage.
- Application Load Balancer.
- Public IPv4 addresses.
- CloudWatch metrics, dashboards, and alarms.
- SNS notifications.
- AWS Fault Injection Service experiment usage.

Actual charges depend on region, duration, traffic, and service usage. Review AWS pricing before deployment and destroy resources when the lab is no longer needed.

## Cleanup

To remove Terraform-managed infrastructure:

```bash
cd terraform
terraform plan -destroy
```

Review the proposed destruction carefully, then execute:

```bash
terraform destroy
```

This removes the managed infrastructure and may permanently terminate application instances and other project resources.

## Project Status

The initial AWS infrastructure has been provisioned.

Verified components include:

- VPC and public subnets.
- Internet Gateway and routing.
- Application Load Balancer and listener.
- Two EC2 instances managed by Auto Scaling.
- Flask application running on both instances.
- Healthy ALB target group registrations.
- Systems Manager connectivity.
- CloudWatch dashboard and alarms.
- SNS topic and confirmed email subscription.

The first controlled FIS termination experiment and recovery measurements remain pending.

External ALB connectivity from the development workstation also requires final verification.

## Learning Outcomes

This project demonstrates practical experience with:

- AWS infrastructure engineering.
- Terraform and Infrastructure as Code.
- High availability and fault tolerance.
- Auto Scaling and load balancing.
- AWS Fault Injection Service.
- CloudWatch observability and alerting.
- IAM security and Systems Manager.
- Incident detection and recovery measurement.
- Site Reliability Engineering principles.

