data "aws_region" "current" {}

resource "aws_elasticsearch_domain" "elk" {
  domain_name           = "${var.domain_name}"
  elasticsearch_version = "${var.elasticsearch_version}"

  // TODO: to see how this part can be organized
  access_policies = <<POLICY
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::*:role/power-user-role"
        ]
      },
      "Action": [
        "es:ESHttpDelete",
        "es:ESHttpGet",
        "es:ESHttpHead",
        "es:ESHttpPost",
        "es:ESHttpPut"
      ],
     "Resource": "arn:aws:es:${data.aws_region.current}:*:domain/${var.domain_name}/*"
   }
 ]
}
POLICY

  cluster_config {
    instance_type            = "${var.instance_type}"
    instance_count           = "${var.instance_count}"
    dedicated_master_enabled = true
    dedicated_master_count   = "${var.dedicated_master_count}"
    dedicated_master_type    = "${var.dedicated_master_type}"
    zone_awareness_enabled   = "${var.zone_awareness_enabled}"
  }

  vpc_options = [{
    security_group_ids = ["${var.vpc_id}"]
    subnet_ids         = ["${var.subnet_ids}"]
  }]

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }

  snapshot_options {
    automated_snapshot_start_hour = "4"
  }

  tags {}
}
