# SNS Topic for infrastructure alerts

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = local.common_tags
}

# Optional email subscription

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Alarm: Unhealthy application targets

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project_name}-unhealthy-hosts"
  alarm_description   = "One or more application targets are unhealthy"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = join("/", slice(split("/", aws_lb.main.arn), 2, 5))
    TargetGroup  = join("/", slice(split("/", aws_lb_target_group.app.arn), 2, 5))
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = local.common_tags
}

# Alarm: Application Load Balancer server errors

resource "aws_cloudwatch_metric_alarm" "alb_errors" {
  alarm_name          = "${var.project_name}-alb-errors"
  alarm_description   = "Load balancer is reporting server errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = join("/", slice(split("/", aws_lb.main.arn), 2, 5))
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = local.common_tags
}

# Alarm: Insufficient EC2 capacity

resource "aws_cloudwatch_metric_alarm" "low_capacity" {
  alarm_name          = "${var.project_name}-low-capacity"
  alarm_description   = "Fewer than two EC2 instances are in service"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 2
  comparison_operator = "LessThanThreshold"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"

  tags = local.common_tags
}

# CloudWatch Dashboard

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title = "Application Load Balancer Requests"
          view  = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              join("/", slice(split("/", aws_lb.main.arn), 2, 5))
            ]
          ]

          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Unhealthy Application Targets"
          view   = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "LoadBalancer",
              join("/", slice(split("/", aws_lb.main.arn), 2, 5)),
              "TargetGroup",
              join("/", slice(split("/", aws_lb_target_group.app.arn), 2, 5))
            ]
          ]

          period = 60
          stat   = "Maximum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Load Balancer HTTP 5XX Errors"
          view   = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              join("/", slice(split("/", aws_lb.main.arn), 2, 5))
            ]
          ]

          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Auto Scaling In-Service Instances"
          view   = "timeSeries"
          region = var.aws_region

          metrics = [
            [
              "AWS/AutoScaling",
              "GroupInServiceInstances",
              "AutoScalingGroupName",
              aws_autoscaling_group.app.name
            ]
          ]

          period = 60
          stat   = "Minimum"
        }
      }
    ]
  })
}