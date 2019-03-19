resource "aws_lb" "vault_lb" {
  name               = "vault-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    "${aws_security_group.vault.id}",
  ]

  subnets = ["${var.subnet_ids}"]

  // TODO: tags
}

resource "aws_lb_target_group" "vault_lb_tg" {
  name        = "vault-lb-tg"
  port        = 8500
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/ui/"
    interval            = 30
  }

  // TODO: tags
}

resource "aws_lb_listener" "vault_lb_listener" {
  load_balancer_arn = "${aws_lb.vault_lb.arn}"
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.vault_lb_tg.arn}"
  }
}

resource "aws_security_group" "vault" {
  name        = "${var.owner}-vault-elb"
  description = "Security group for the ${var.owner} vault ELB"
  vpc_id      = "${var.vpc_id}"

  // TODO: tags
}

resource "aws_security_group_rule" "allow_inbound_api" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.vault.id}"
}
