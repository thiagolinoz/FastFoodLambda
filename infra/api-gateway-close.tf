resource "aws_api_gateway_rest_api" "rest_api_pessoa" {
  name        = "pessoa"
  description = "API para autenticação"
}

# /api
resource "aws_api_gateway_resource" "api_pessoa" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  parent_id   = aws_api_gateway_rest_api.rest_api_pessoa.root_resource_id
  path_part   = "api"
}

# /api/v1
resource "aws_api_gateway_resource" "v1_pessoa" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  parent_id   = aws_api_gateway_resource.api_pessoa.id
  path_part   = "v1"
}

# /api/v1/pessoa
resource "aws_api_gateway_resource" "pessoa" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  parent_id   = aws_api_gateway_resource.v1_pessoa.id
  path_part   = "pessoa"
}

# /api/v1/pessoa/{cdDocPessoa}
resource "aws_api_gateway_resource" "pessoa_item" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  parent_id   = aws_api_gateway_resource.pessoa.id
  path_part   = "{cdDocPessoa}"  # <-- path parameter
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                    = "lambda-authorizer"
  rest_api_id             = aws_api_gateway_rest_api.rest_api_pessoa.id
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer.arn}/invocations" #aws_lambda_function.authorizer.invoke_arn
  #authorizer_credentials = var.role_lab
  identity_source        = "method.request.header.Authorization"
  type                   = "REQUEST"
#   provider_arns           = [aws_cognito_user_pool.main.arn]
}
#
# ####################################
#
#
#
# GET /api/v1/pessoa/{cdDocPessoa}
resource "aws_api_gateway_method" "pessoa_item_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_pessoa.id
  resource_id   = aws_api_gateway_resource.pessoa_item.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true  # <-- obriga o header
    "method.request.path.cdDocPessoa" = true  # obrigatório
  }
}
#
# Integração com backend
resource "aws_api_gateway_integration" "pessoa_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_pessoa.id
  resource_id             = aws_api_gateway_resource.pessoa_item.id
  http_method             = aws_api_gateway_method.pessoa_item_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://a7fa5d3f45abb4c4fa35d8e131643057-211637257.us-east-1.elb.amazonaws.com/api/v1/pessoa/{cdDocPessoa}"

  request_parameters = {
    "integration.request.path.cdDocPessoa" = "method.request.path.cdDocPessoa"
  }
}

#==========================================================

# # Cria o deployment
# resource "aws_api_gateway_deployment" "pessoa_deployment" {
#   depends_on = [
#     aws_api_gateway_integration.pessoa_item_integration,
#     aws_api_gateway_method.pessoa_item_get
#   ]
#
#   rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
#   description = "Deployment for /api/v1/pessoa/{cdDocPessoa}"
# }
#
# # Cria o stage 'prod'
# resource "aws_api_gateway_stage" "pessoa_stage" {
#   stage_name    = "prd"
#   rest_api_id   = aws_api_gateway_rest_api.rest_api_pessoa.id
#   deployment_id = aws_api_gateway_deployment.pessoa_deployment.id
#
#   variables = {
#     # aqui você pode definir variáveis de stage se quiser
#   }
# }
resource "aws_api_gateway_deployment" "pessoa_deployment" {
  depends_on = [
    aws_api_gateway_integration.pessoa_item_integration,
    aws_api_gateway_method.pessoa_item_get,
    aws_api_gateway_authorizer.lambda_authorizer
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  description = "Deployment for /api/v1/pessoa/{cdDocPessoa}"

  # Força nova deployment quando há mudanças
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.pessoa_item.id,
      aws_api_gateway_method.pessoa_item_get.id,
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
  rest_api_id   = aws_api_gateway_rest_api.rest_api_pessoa.id
  deployment_id = aws_api_gateway_deployment.pessoa_deployment.id

  variables = {
    # aqui você pode definir variáveis de stage se quiser
  }
}