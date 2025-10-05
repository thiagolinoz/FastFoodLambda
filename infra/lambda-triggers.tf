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

data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "postech-fiap-fastfood-authorizer.zip"

  source {
    content  = <<EOF
import json
import boto3
import os
import re
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        # Para authorizer REQUEST, o token vem em headers
        headers = event.get('headers', {})
        method_arn = event.get('methodArn', '')

        # Busca o token no header Authorization
        authorization_header = headers.get('Authorization', '') or headers.get('authorization', '')

        if not authorization_header:
            logger.error("Authorization header not found")
            return generate_policy('user', "Deny", method_arn)

        if not method_arn:
            logger.error("methodArn not found in event")
            return generate_policy('user', "Deny", method_arn)

        # Remove 'Bearer ' do token se presente
        token = authorization_header
        if token.startswith('Bearer '):
            token = token[7:]
        elif token.startswith('bearer '):
            token = token[7:]

        logger.info(f"Processing token: {token[:15]}... for method: {method_arn}")
        logger.info(f"HTTP Method: {event.get('httpMethod')} | Resource: {event.get('resource')}")

        # Validação simples do token (em produção, valide JWT do Cognito)
        if len(token) > 10:  # Token válido básico
            logger.info("Token is valid, allowing access")
            return generate_policy('user', "Allow", method_arn, event)
        else:
            logger.warning("Token is invalid, denying access")
            return generate_policy('user', "Deny", method_arn, event)

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        import traceback
        logger.error(f"Traceback: {traceback.format_exc()}")
        return generate_policy('user', "Deny", method_arn or "", event)

def generate_policy(principal_id, effect, resource, event=None):
    """
    Gera uma policy IAM para API Gateway REST com authorizer REQUEST
    """

    # Para authorizer REQUEST, podemos usar wildcard para permitir todos os métodos da API
    resource_arn = resource
    if effect == "Allow":
        # Permite acesso a todos os recursos da API
        parts = resource.split('/')
        if len(parts) >= 3:
            # arn:aws:execute-api:region:account:api-id/stage/*/*
            base_arn = '/'.join(parts[:3])
            resource_arn = f"{base_arn}/*/*"

    policy = {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource_arn
            }]
        }
    }

    # Adiciona contexto que pode ser usado nas integrações
    if effect == "Allow" and event:
        policy['context'] = {
            'userId': principal_id,
            'httpMethod': event.get('httpMethod', ''),
            'resourcePath': event.get('resource', ''),
            'sourceIp': event.get('requestContext', {}).get('identity', {}).get('sourceIp', ''),
            'userAgent': event.get('headers', {}).get('User-Agent', '')
        }

    logger.info(f"Generated policy: {json.dumps(policy)}")
    return policy
EOF
    filename = "index.py"
  }
}