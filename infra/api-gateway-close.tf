resource "aws_api_gateway_rest_api" "rest_api_fastfood" {
  name        = "fastfood"
  description = "API para gerenciamento de pedidos e pagamentos"
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                    = "lambda-authorizer"
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer.arn}/invocations" #aws_lambda_function.authorizer.invoke_arn
  #authorizer_credentials = var.role_lab
  identity_source        = "method.request.header.Authorization"
  type                   = "REQUEST"
  #   provider_arns           = [aws_cognito_user_pool.main.arn]
  authorizer_result_ttl_in_seconds = 0 # <--- sem cache
}

# /api
resource "aws_api_gateway_resource" "api_fastfood" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_rest_api.rest_api_fastfood.root_resource_id
  path_part   = "api"
}

# /api/v1
resource "aws_api_gateway_resource" "v1_fastfood" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.api_fastfood.id
  path_part   = "v1"
}

resource "aws_api_gateway_deployment" "fastfood_deployment" {
  depends_on = [
    aws_api_gateway_integration.pessoa_item_integration,
    aws_api_gateway_method.pessoa_item_get,
    aws_api_gateway_authorizer.lambda_authorizer
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  description = "Deployment for /api/v1/pessoa/{cdDocPessoa}"

  # Força nova deployment quando há mudanças
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.pessoa_item.id,
      aws_api_gateway_method.pessoa_item_get.id,
      aws_api_gateway_method.pessoa_post.id,
      aws_api_gateway_integration.pessoa_item_integration.id,
      aws_api_gateway_authorizer.lambda_authorizer.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Cria o stage 'prod'
resource "aws_api_gateway_stage" "pessoa_stage" {
  stage_name    = "producao"
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  deployment_id = aws_api_gateway_deployment.fastfood_deployment.id

  variables = {
    # aqui você pode definir variáveis de stage se quiser
  }
}