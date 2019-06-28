resource "aws_db_instance" "grafana" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  identifier             = "grafana-mysql"
  name                   = "grafana"
  username               = "admin"
  skip_final_snapshot    = true
  password               = "${var.grafana_admin_password}"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.grafana_db_sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.grafana_db_subnet_group.name}"
}

resource "aws_security_group" "grafana_db_sg" {
  name        = "allow local connections for grafana database"
  description = "local traffic to 3306"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_mysql_port" {
  type              = "ingress"
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.grafana_db_sg.id}"
}

resource "aws_security_group_rule" "mysql_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.grafana_db_sg.id}"
}

resource "aws_db_subnet_group" "grafana_db_subnet_group" {
  name       = "grafana_db_subnet_group"
  subnet_ids = ["${var.subnet_id}"]

  tags {
    Name = "Grafana DB subnet group"
  }
}

resource "aws_alb" "grafana_alb" {
  name         = "grafana-alb"
  internal     = true
  idle_timeout = "300"

  security_groups = [
    "${aws_security_group.prom_grafana_alb_sg.id}",
  ]

  subnets                    = ["${var.subnet_id}"]
  enable_deletion_protection = false

  tags {
    Name = "grafana_alb"
  }
}

resource "aws_alb_listener" "grafana_alb_listener" {
  load_balancer_arn = "${aws_alb.grafana_alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2015-05"
  # certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.grafana_tg.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "grafana_tg" {
  name     = "grafana-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path    = "/"
    matcher = "200,302"
  }
}

resource "aws_alb_listener_rule" "grafana_listener_rule" {
  listener_arn = "${aws_alb_listener.grafana_alb_listener.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.grafana_tg.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}
