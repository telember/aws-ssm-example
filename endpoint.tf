# locals {
#   services = {
#     "ec2messages" : {
#       "name" : "com.amazonaws.${var.region}.ec2messages"
#     },
#     "ssm" : {
#       "name" : "com.amazonaws.${var.region}.ssm"
#     },
#     "ssmmessages" : {
#       "name" : "com.amazonaws.${var.region}.ssmmessages"
#     }
#   }
# }

# resource "aws_vpc_endpoint" "ssm_endpoint" {
#   for_each = local.services
#   vpc_id   = aws_vpc.main.id

#   service_name        = each.value.name
#   vpc_endpoint_type   = "Interface"
#   security_group_ids  = [aws_security_group.ssm_https.id]
#   private_dns_enabled = true
#   ip_address_type     = "ipv4"
#   subnet_ids          = [aws_subnet.main_subnet.id]
# }