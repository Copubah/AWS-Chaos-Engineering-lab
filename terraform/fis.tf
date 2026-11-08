# FIS trust policy
data "aws_iam_policy_document" "fis_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["fis.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# FIS execution role
resource "aws_iam_role" "fis" {
  name               = "${var.project_name}-fis-role"
  assume_role_policy = data.aws_iam_policy_document.fis_assume_role.json

  tags = local.common_tags
}

# FIS permissions
data "aws_iam_policy_document" "fis_permissions" {
  statement {
    sid    = "DescribeInstances"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "TerminateProjectInstances"
    effect = "Allow"

    actions = [
      "ec2:TerminateInstances"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:*:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Project"
      values   = [var.project_name]
    }
  }
}

resource "aws_iam_role_policy" "fis_permissions" {
  name   = "${var.project_name}-fis-permissions"
  role   = aws_iam_role.fis.id
  policy = data.aws_iam_policy_document.fis_permissions.json
}

# EC2 termination experiment
resource "aws_fis_experiment_template" "terminate_instance" {
  description = "Terminate one ResilienceLab EC2 instance and test automatic recovery"

  role_arn = aws_iam_role.fis.arn

  action {
    name      = "terminate-one-instance"
    action_id = "aws:ec2:terminate-instances"

    target {
      key   = "Instances"
      value = "resilience-lab-instances"
    }
  }

  target {
    name           = "resilience-lab-instances"
    resource_type  = "aws:ec2:instance"
    selection_mode = "COUNT(1)"

    resource_tag {
      key   = "Project"
      value = var.project_name
    }
  }

  stop_condition {
    source = "aws:cloudwatch:alarm"
    value  = aws_cloudwatch_metric_alarm.low_capacity.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-terminate-experiment"
  })
}
