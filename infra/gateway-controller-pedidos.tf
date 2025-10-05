######################################
# /api/v1/pedidos
######################################
resource "aws_api_gateway_resource" "pedidos" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.v1_fastfood.id
  path_part   = "pedidos"
}

######################################
# GET /api/v1/pedidos
######################################
resource "aws_api_gateway_method" "pedidos_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pedidos.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "pedidos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pedidos.id
  http_method             = aws_api_gateway_method.pedidos_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/pedidos"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

######################################
# POST /api/v1/pedidos/checkout
######################################
resource "aws_api_gateway_resource" "pedidos_checkout" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos.id
  path_part   = "checkout"
}

resource "aws_api_gateway_method" "pedidos_checkout_post" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pedidos_checkout.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "pedidos_checkout_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pedidos_checkout.id
  http_method             = aws_api_gateway_method.pedidos_checkout_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/pedidos/checkout"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

######################################
# PATCH /api/v1/pedidos/{cdPedido}/status/{txStatus}
######################################
resource "aws_api_gateway_resource" "pedidos_cdPedido" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos.id
  path_part   = "{cdPedido}"
}

resource "aws_api_gateway_resource" "pedidos_status" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos_cdPedido.id
  path_part   = "status"
}

resource "aws_api_gateway_resource" "pedidos_status_txStatus" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos_status.id
  path_part   = "{txStatus}"
}

resource "aws_api_gateway_method" "pedidos_status_patch" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pedidos_status_txStatus.id
  http_method   = "PATCH"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.cdPedido"        = true
    "method.request.path.txStatus"        = true
  }
}

resource "aws_api_gateway_integration" "patch_pedidos_status_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pedidos_status_txStatus.id
  http_method             = aws_api_gateway_method.pedidos_status_patch.http_method
  integration_http_method = "PATCH"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/pedidos/{cdPedido}/status/{txStatus}"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.cdPedido"        = "method.request.path.cdPedido"
    "integration.request.path.txStatus"        = "method.request.path.txStatus"
  }
}

######################################
# GET /api/v1/pedidos/{nrPedidos}/pagamento/status
######################################
resource "aws_api_gateway_resource" "pedidos_pagamento" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos_cdPedido.id   #
  path_part   = "pagamento"
}

resource "aws_api_gateway_resource" "pedidos_pagamento_status" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pedidos_pagamento.id
  path_part   = "status"
}

resource "aws_api_gateway_method" "pedidos_pagamento_status_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pedidos_pagamento_status.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.cdPedido"        = true
  }
}

resource "aws_api_gateway_integration" "pedidos_pagamento_status_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pedidos_pagamento_status.id
  http_method             = aws_api_gateway_method.pedidos_pagamento_status_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"


  uri = "${var.host_elb}/api/v1/pedidos/{nrPedidos}/pagamento/status"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"

    "integration.request.path.nrPedidos"       = "method.request.path.cdPedido"
  }
}
