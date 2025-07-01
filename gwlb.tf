################################################################################
# GWLB
################################################################################

data "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  provider = aws.ocp_inspection_network
  filter {
    name   = "tag:Name"
    values = [local.inspection-gwlb-endpoint-service]
  }
}

resource "aws_vpc_endpoint_service_allowed_principal" "allow_other_account" {
  provider = aws.ocp_inspection_network

  count                   = local.create_gwlb ? 1 : 0
  vpc_endpoint_service_id = data.aws_vpc_endpoint_service.gwlb_endpoint_service.id
  principal_arn           = "arn:aws:iam::${var.target_account_id}:root"
}

output "gwlb_endpoint_service" {  
  value = data.aws_vpc_endpoint_service.gwlb_endpoint_service.id
  description = "The ID of the GWLB endpoint service"
  
}