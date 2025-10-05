###############################################
# /api/v1/produto
###############################################
resource "aws_api_gateway_resource" "produto" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.v1_fastfood.id
  path_part   = "produto"
}

# POST /api/v1/produto
resource "aws_api_gateway_method" "produto_post" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produto.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "post_produto_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produto.id
  http_method             = aws_api_gateway_method.produto_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produto"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

###############################################
# /api/v1/produtos
###############################################
resource "aws_api_gateway_resource" "produtos" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.v1_fastfood.id
  path_part   = "produtos"
}

# GET /api/v1/produtos
resource "aws_api_gateway_method" "produtos_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produtos.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "get_produtos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produtos.id
  http_method             = aws_api_gateway_method.produtos_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produtos"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

###############################################
# /api/v1/produtos/categoria
###############################################
resource "aws_api_gateway_resource" "produtos_categoria" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.produtos.id # ✅ filho de /produtos
  path_part   = "categoria"
}

# GET /api/v1/produtos/categoria
resource "aws_api_gateway_method" "produtos_categoria_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produtos_categoria.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization"     = true
    "method.request.querystring.tpCategoria"  = true
  }
}

resource "aws_api_gateway_integration" "get_produtos_categoria_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produtos_categoria.id
  http_method             = aws_api_gateway_method.produtos_categoria_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produtos/categoria"

  request_parameters = {
    "integration.request.header.Authorization"     = "method.request.header.Authorization"
    "integration.request.querystring.tpCategoria"  = "method.request.querystring.tpCategoria"
  }
}

###############################################
# /api/v1/produto/{cdProduto}
###############################################
resource "aws_api_gateway_resource" "produto_item" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "{cdProduto}"
}

# PUT /api/v1/produto/{cdProduto}
resource "aws_api_gateway_method" "produto_put" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produto_item.id
  http_method   = "PUT"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.cdProduto"       = true
  }
}

resource "aws_api_gateway_integration" "put_produto_item_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produto_item.id
  http_method             = aws_api_gateway_method.produto_put.http_method
  integration_http_method = "PUT"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produto/{cdProduto}"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.cdProduto"       = "method.request.path.cdProduto"
  }
}

###############################################
# /api/v1/produto/{cdProduto}/ativar
###############################################
resource "aws_api_gateway_resource" "produto_item_ativar" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.produto_item.id
  path_part   = "ativar"
}

resource "aws_api_gateway_method" "produto_item_ativar_patch" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produto_item_ativar.id
  http_method   = "PATCH"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.cdProduto"       = true
  }
}

resource "aws_api_gateway_integration" "patch_produto_item_ativar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produto_item_ativar.id
  http_method             = aws_api_gateway_method.produto_item_ativar_patch.http_method
  integration_http_method = "PATCH"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produto/{cdProduto}/ativar"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.cdProduto"       = "method.request.path.cdProduto"
  }
}

###############################################
# /api/v1/produto/{cdProduto}/desativar
###############################################
resource "aws_api_gateway_resource" "produto_item_desativar" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_fastfood.id
  parent_id   = aws_api_gateway_resource.produto_item.id
  path_part   = "desativar"
}

resource "aws_api_gateway_method" "produto_item_desativar_patch" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id   = aws_api_gateway_resource.produto_item_desativar.id
  http_method   = "PATCH"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id

  request_parameters = {
    "method.request.header.Authorization" = true
    "method.request.path.cdProduto"       = true
  }
}

resource "aws_api_gateway_integration" "patch_produto_item_desativar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_fastfood.id
  resource_id             = aws_api_gateway_resource.produto_item_desativar.id
  http_method             = aws_api_gateway_method.produto_item_desativar_patch.http_method
  integration_http_method = "PATCH"
  type                    = "HTTP_PROXY"
  uri                     = "${var.host_elb}/api/v1/produto/{cdProduto}/desativar"

  request_parameters = {
    "integration.request.header.Authorization" = "method.request.header.Authorization"
    "integration.request.path.cdProduto"       = "method.request.path.cdProduto"
  }
}
