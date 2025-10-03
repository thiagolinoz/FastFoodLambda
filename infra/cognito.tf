# resource "aws_cognito_user_pool" "user_pool" {
#   name = "fiap-fastfood-users"
# }
#
# resource "aws_cognito_user_pool_client" "user_pool_client" {
#   name         = "fiap-fastfood-client"
#   user_pool_id = aws_cognito_user_pool.user_pool.id
#   generate_secret = false
# }

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"
  lambda_config {
    create_auth_challenge = aws_lambda_function.CreateAuthChallenge.arn #"arn:aws:lambda:us-east-1:318969550207:function:postech-fiap-fastfood-CreateAuthChallenge-function"
    define_auth_challenge = aws_lambda_function.DefineAuthChallenge.arn #"arn:aws:lambda:us-east-1:318969550207:function:postech-fiap-fastfood-DefineAuthChallenge-function"
    verify_auth_challenge_response = aws_lambda_function.VerifyAuthChallengeResponse.arn #"arn:aws:lambda:us-east-1:318969550207:function:postech-fiap-fastfood-VerifyAuthChallengeResponse-function"
  }
  # Configurações de senha
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

# Cognito User Pool Client
}
resource "aws_cognito_user_pool_client" "main_pool_client" {
  name         = "${var.project_name}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Configurações de autenticação
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH"
  ]

  # Configurações de token
  access_token_validity  = 60    # 1 hora
  id_token_validity      = 60    # 1 hora
  refresh_token_validity = 30    # 30 dias

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  generate_secret = false # Para aplicações web públicas
}

