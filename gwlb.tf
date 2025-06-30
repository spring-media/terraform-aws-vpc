################################################################################
# GWLB
################################################################################

resource "aws_lb" "gwlb" {
  count              = local.create_gwlb ? 1 : 0
  name               = "gwlb-inspection"
  internal           = true
  load_balancer_type = "gateway"
  subnets            = [for subnet in aws_subnet.gwlb : subnet.id]

  tags = {
    Name = "gwlb-inspection"
  }
}

resource "aws_lb_target_group" "gwlb_tg" {
  count       = local.create_gwlb ? 1 : 0
  name        = "gwlb-target-group"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 5
  }

  tags = {
    Name = "gwlb-target-group"
  }
}

resource "aws_lb_listener" "gwlb_listener" {
  count             = local.create_gwlb ? 1 : 0
  load_balancer_arn = aws_lb.gwlb[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlb_tg[0].arn
  }
}

resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  count                      = local.create_gwlb ? 1 : 0
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb[0].arn]

  tags = {
    Name = local.inspection-gwlb-endpoint-service
  }
}

resource "aws_vpc_endpoint_service_allowed_principal" "allow_other_account" {
  count                   = local.create_gwlb ? 1 : 0
  vpc_endpoint_service_id = aws_vpc_endpoint_service.gwlb_endpoint_service[0].id
  principal_arn           = "arn:aws:iam::${var.target_account_id}:root"
}