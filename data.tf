data "aws_vpc" "this" {
  id = "${var.vpc_id}"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.this.arn}"]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}
