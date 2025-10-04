########################################
# Empacota código Lambda em ZIP
########################################
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "postech-fiap-fastfood-login.zip"

  source {
    content  = <<EOF
import json
import boto3
import hmac
import hashlib
import base64

# Configurações do Cognito
USER_POOL_CLIENT_ID = "76k10febb0nlcqhchi01affm67"
USER_POOL_CLIENT_SECRET = "u1k9e19a13ftvdknr0110iei2q1uevsq24223vopi8diemrttq5"  # deixe vazio se não tiver secret

cognito = boto3.client("cognito-idp")

def get_secret_hash(username):
    if not USER_POOL_CLIENT_SECRET:
        return None
    message = username + USER_POOL_CLIENT_ID
    dig = hmac.new(
        str(USER_POOL_CLIENT_SECRET).encode("utf-8"),
        msg=message.encode("utf-8"),
        digestmod=hashlib.sha256
    ).digest()
    return base64.b64encode(dig).decode()

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        username = body.get("username")

        if not username:
            return {"statusCode": 400, "body": json.dumps({"error": "username required"})}

        auth_params = { "USERNAME": username }

        secret_hash = get_secret_hash(username)
        if secret_hash:
            auth_params["SECRET_HASH"] = secret_hash

        response = cognito.initiate_auth(
            ClientId=USER_POOL_CLIENT_ID,
            AuthFlow="CUSTOM_AUTH",
            AuthParameters=auth_params
        )

        access_token = response["AuthenticationResult"]["AccessToken"]

        return {
            "statusCode": 200,
            "body": json.dumps({"accessToken": access_token})
        }

    except cognito.exceptions.NotAuthorizedException:
        return {"statusCode": 401, "body": json.dumps({"error": "Invalid username"})}
    except cognito.exceptions.UserNotFoundException:
        return {"statusCode": 404, "body": json.dumps({"error": "User does not exist"})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
EOF
    filename = "index.py"
  }
}

########################################
# Função Lambda
########################################
resource "aws_lambda_function" "main" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-login-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
resource "aws_lambda_function" "DefineAuthChallenge" {
  filename      = data.archive_file.DefineAuthChallenge.output_path
  function_name = "${var.project_name}-DefineAuthChallenge-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.DefineAuthChallenge.output_base64sha256
}
resource "aws_lambda_function" "VerifyAuthChallengeResponse" {
  filename      = data.archive_file.VerifyAuthChallengeResponse.output_path
  function_name = "${var.project_name}-VerifyAuthChallengeResponse-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.VerifyAuthChallengeResponse.output_base64sha256
}
resource "aws_lambda_function" "CreateAuthChallenge" {
  filename      = data.archive_file.CreateAuthChallenge.output_path
  function_name = "${var.project_name}-CreateAuthChallenge-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.CreateAuthChallenge.output_base64sha256
}
resource "aws_lambda_function" "authorizer" {
  filename      = data.archive_file.authorizer.output_path
  function_name = "${var.project_name}-authorizer-function"
  role          = var.role_lab # deve ser ARN de role válida
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30
  tags          = var.tags

  source_code_hash = data.archive_file.authorizer.output_base64sha256
}
resource "aws_lambda_permission" "allow_cognito_define" {
  statement_id  = "AllowExecutionFromCognitoDefine"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DefineAuthChallenge.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.main.arn
}

resource "aws_lambda_permission" "allow_cognito_create" {
  statement_id  = "AllowExecutionFromCognitoCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CreateAuthChallenge.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.main.arn
}

resource "aws_lambda_permission" "allow_cognito_verify" {
  statement_id  = "AllowExecutionFromCognitoVerify"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.VerifyAuthChallengeResponse.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.main.arn
}

# resource "aws_lambda_permission" "apigw_invoke" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.authorizer.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.rest_api_pessoa.execution_arn}/authorizers/${aws_api_gateway_authorizer.lambda_authorizer.id}"
# }
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  # Permissão ampla para o API Gateway invocar o authorizer
  source_arn    = "${aws_api_gateway_rest_api.rest_api_pessoa.execution_arn}/*"
}
# Permissão para API Gateway invocar o Lambda Authorizer
resource "aws_lambda_permission" "apigw_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api_pessoa.execution_arn}/*/*"
}
########################################
# Log Group CloudWatch (opcional)
########################################
# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
#   retention_in_days = 14
# }
