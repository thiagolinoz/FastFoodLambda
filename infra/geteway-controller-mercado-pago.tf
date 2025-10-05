resource "aws_api_gateway_resource" "webhook" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_rest_api.rest_api_fastfood.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_resource" "webhook_mercado_pago" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.webhook.id
  path_part   = "mercado-pago"
}

resource "aws_api_gateway_resource" "webhook_mercado_pago_pagamentos" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.webhook_mercado_pago.id
  path_part   = "pagamentos"
}

resource "aws_api_gateway_resource" "webhook_mercado_pago_pagamentos_nrPedido" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.webhook_mercado_pago_pagamentos.id
  path_part   = "{nrPedido}"
}

resource "aws_api_gateway_method" "webhook_mercado_pago_pagamentos_nrPedido_post" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.webhook_mercado_pago_pagamentos_nrPedido.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.nrPedido" = true
  }
}

resource "aws_api_gateway_integration" "webhook_mercado_pago_pagamentos_nrPedido_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.webhook_mercado_pago_pagamentos_nrPedido.id
  http_method             = aws_api_gateway_method.webhook_mercado_pago_pagamentos_nrPedido_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/webhook/mercado-pago/pagamentos/{nrPedido}"
  request_parameters = {
    "integration.request.path.nrPedido" = "method.request.path.nrPedido"
  }
}
