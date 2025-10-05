# /api/v1/pessoa
resource "aws_api_gateway_resource" "pessoa" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.v1_fastfood.id
  path_part   = "pessoa"
}

# POST /api/v1/pessoa
resource "aws_api_gateway_method" "pessoa_post" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pessoa.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
  #request_validator_id = "mrcrk3" #remover?
  #api_key_required     = true #remover?
  request_parameters = {
    "method.request.header.Authorization" = true  # <-- obriga o header
  }
}
# Integração com backend
resource "aws_api_gateway_integration" "pessoa_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pessoa.id
  http_method             = aws_api_gateway_method.pessoa_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/pessoa"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization" #remover?
  }
}

# /api/v1/pessoa/{cdDocPessoa}
resource "aws_api_gateway_resource" "pessoa_item" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.pessoa.id
  path_part   = "{cdDocPessoa}"  # <-- path parameter
}

# GET /api/v1/pessoa/{cdDocPessoa}
resource "aws_api_gateway_method" "pessoa_item_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.pessoa_item.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  #request_validator_id = "mrcrk3" #remover?
  #api_key_required     = true #remover?

  request_parameters = {
    "method.request.header.Authorization" = true  # <-- obriga o header
    "method.request.path.cdDocPessoa" = true  # obrigatório
  }
}

# Integração com backend
resource "aws_api_gateway_integration" "pessoa_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.pessoa_item.id
  http_method             = aws_api_gateway_method.pessoa_item_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/pessoa/{cdDocPessoa}"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization" #remover?
    "integration.request.path.cdDocPessoa" = "method.request.path.cdDocPessoa"
  }
}