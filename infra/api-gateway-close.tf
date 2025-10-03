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

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                    = "cognito-authorizer"
  rest_api_id             = aws_api_gateway_rest_api.rest_api_pessoa.id
  identity_source         = "method.request.header.Authorization"
  type                    = "COGNITO_USER_POOLS"
  provider_arns           = [aws_cognito_user_pool.main.arn]
}

####################################



# GET /api/v1/pessoa/{cdDocPessoa}
resource "aws_api_gateway_method" "pessoa_item_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_pessoa.id
  resource_id   = aws_api_gateway_resource.pessoa_item.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.header.Authorization" = true  # <-- obriga o header
    "method.request.path.cdDocPessoa" = true  # obrigatório
  }
}

# Integração com backend
resource "aws_api_gateway_integration" "pessoa_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_pessoa.id
  resource_id             = aws_api_gateway_resource.pessoa_item.id
  http_method             = aws_api_gateway_method.pessoa_item_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://a013aae710b8a44f2a83cf3b3e1a70e9-433294589.us-east-1.elb.amazonaws.com/api/v1/pessoa/{cdDocPessoa}"

  request_parameters = {
    "integration.request.path.cdDocPessoa" = "method.request.path.cdDocPessoa"
  }
}

# Cria o deployment
resource "aws_api_gateway_deployment" "pessoa_deployment" {
  depends_on = [
    aws_api_gateway_integration.pessoa_item_integration,
    aws_api_gateway_method.pessoa_item_get
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api_pessoa.id
  description = "Deployment for /api/v1/pessoa/{cdDocPessoa}"
}

# Cria o stage 'prod'
resource "aws_api_gateway_stage" "pessoa_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.rest_api_pessoa.id
  deployment_id = aws_api_gateway_deployment.pessoa_deployment.id

  variables = {
    # aqui você pode definir variáveis de stage se quiser
  }
}