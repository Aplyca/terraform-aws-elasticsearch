locals {
  id = "${replace(var.name, " ", "-")}"
}

# -----------------------------------------------
# Create Private subnets
# -----------------------------------------------
resource "aws_subnet" "this" {
  count = "${length(var.azs)}"
  vpc_id = "${data.aws_vpc.this.id}"
  cidr_block = "${cidrsubnet(data.aws_vpc.this.cidr_block, var.newbits, var.netnum + count.index)}"
	availability_zone = "${element(var.azs, count.index)}"
	map_public_ip_on_launch = false
  tags = "${merge(var.tags, map("Name", "${var.name} ES ${count.index}"))}"
}

# ---------------------------------------
# Network ACL DB
# ---------------------------------------
resource "aws_network_acl" "this" {
  vpc_id = "${data.aws_vpc.this.id}"
  subnet_ids = ["${aws_subnet.this.*.id}"]
  tags = "${merge(var.tags, map("Name", "${var.name} ES"))}"
}

# ---------------------------------------
# Network ACL Inbound/Outbound DB
# ---------------------------------------
resource "aws_network_acl_rule" "inbound_https" {
  count = "${length(var.access_cidrs)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${100+count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.access_cidrs, count.index)}"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "inbound_http" {
  count = "${length(var.access_cidrs)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${(200+count.index)}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.access_cidrs, count.index)}"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "outbound" {
  count = "${length(var.access_cidrs)}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${(count.index+1)*100}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${element(var.access_cidrs, count.index)}"
  from_port      = 1024
  to_port        = 65535
}

# Security group Database access
resource "aws_security_group" "this" {
  name = "${local.id}-ES"
  description = "Access to ElasticSearch port"
  vpc_id = "${data.aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", "${var.name} ES"))}"
}

resource "aws_security_group_rule" "egress" {
  type            = "egress"
  security_group_id = "${aws_security_group.this.id}"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  description = "Access to all egress targets"
}

resource "aws_security_group_rule" "ingress_https" {
  count = "${length(var.access_sg_ids)}"
  type            = "ingress"
  security_group_id = "${aws_security_group.this.id}"
  from_port       = "443"
  to_port         = "443"
  protocol        = "tcp"
  source_security_group_id = "${element(var.access_sg_ids, count.index)}"
  description = "Access from Source"
}

resource "aws_security_group_rule" "ingress_http" {
  count = "${length(var.access_sg_ids)}"
  type            = "ingress"
  security_group_id = "${aws_security_group.this.id}"
  from_port       = "80"
  to_port         = "80"
  protocol        = "tcp"
  source_security_group_id = "${element(var.access_sg_ids, count.index)}"
  description = "Access from Source"
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${lower(local.id)}"
  elasticsearch_version = "${var.es_version}"
  cluster_config {
    instance_type = "${var.type}"
    instance_count = "${var.instances}"
  }

  vpc_options {
    security_group_ids = ["${aws_security_group.this.id}"]
    subnet_ids = ["${aws_subnet.this.*.id}"]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.storage}"
  }

  snapshot_options {
    automated_snapshot_start_hour = 1
  }

  tags = "${merge(var.tags, map("Name", var.name))}"
}


resource "aws_elasticsearch_domain_policy" "this" {
  domain_name = "${aws_elasticsearch_domain.this.domain_name}"

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "${aws_elasticsearch_domain.this.arn}/*"
    }
  ]
}
POLICIES
}
