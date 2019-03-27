resource "aws_security_group" "db_sg" {
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "postgres_sgr" {
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.server_sg.id}"
  security_group_id        = "${aws_security_group.db_sg.id}"
}

resource "aws_db_subnet_group" "drone" {
  name       = "${join("-", list(var.owner, var.project, terraform.workspace))}"
  subnet_ids = ["${var.db_subnet_ids}"]

  // TODO: tags {}
}

resource "aws_db_instance" "default" {
  allocated_storage         = 20
  multi_az                  = true
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = "11.1"
  instance_class            = "db.t3.small"
  name                      = "dronedb"
  username                  = "drone"
  password                  = "${random_string.db_password.result}"
  parameter_group_name      = "${aws_db_parameter_group.postgres.name}"
  apply_immediately         = true
  db_subnet_group_name      = "${aws_db_subnet_group.drone.name}"
  vpc_security_group_ids    = ["${aws_security_group.db_sg.id}"]
  final_snapshot_identifier = "${join("-", list(var.owner, var.project, terraform.workspace, replace(timestamp(), ":", "-")) )}"

  //  TODO: tags {}
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${join("-", list(var.owner, var.project, "postgres11", terraform.workspace))}"
  family = "postgres11"
}
