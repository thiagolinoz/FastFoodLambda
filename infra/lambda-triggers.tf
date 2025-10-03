data "archive_file" "DefineAuthChallenge" {
  type        = "zip"
  output_path = "postech-fiap-fastfood-DefineAuthChallenge.zip"

  source {
    content  = <<EOF
def lambda_handler(event, context):
    # Se for a primeira chamada de auth, já definimos que está autenticado
    event['response']['challengeName'] = None
    event['response']['issueTokens'] = True
    event['response']['failAuthentication'] = False
  return event
EOF
    filename = "index.py"
  }
}

data "archive_file" "VerifyAuthChallengeResponse" {
  type        = "zip"
  output_path = "postech-fiap-fastfood-VerifyAuthChallengeResponse.zip"

  source {
    content  = <<EOF
def lambda_handler(event, context):
    # Aceita direto
    event['response']['answerCorrect'] = True
    return event
EOF
    filename = "index.py"
  }
}

data "archive_file" "CreateAuthChallenge" {
  type        = "zip"
  output_path = "postech-fiap-fastfood-CreateAuthChallenge.zip"

  source {
    content  = <<EOF
def lambda_handler(event, context):
    # Não criamos nenhum challenge
    return event
EOF
    filename = "index.py"
  }
}