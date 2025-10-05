import json
import urllib.request
import urllib.error

API_URL = "SUA_URL_BASE_AQUI/api/v1/pessoa"

def lambda_handler(event, context):
    """
    Função Lambda para fazer um POST no endpoint /api/v1/pessoa.

    Espera-se que o corpo da requisição (se vier do API Gateway)
    esteja em event['body'].
    """

    # 1. Tenta extrair e desserializar os dados de entrada
    try:
        # Se vier do API Gateway, o corpo é uma string JSON
        if event.get('body'):
            input_data = json.loads(event['body'])
        else:
            # Caso contrário, assume que os dados estão diretamente no 'event'
            input_data = event

    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Requisição inválida: Corpo JSON malformado'})
        }

    # 2. Constrói o payload JSON com os parâmetros exigidos
    payload = {
        "cdDocPessoa": input_data.get("cpf", ""),
        "nmPessoa": "A definir",
        "tpPessoa": "CLIENTE",
        "dsEmail": "a definir"
    }

    # Serializa o dicionário Python para uma string de bytes JSON,
    # pois o urllib.request espera o corpo como bytes.
    data_bytes = json.dumps(payload).encode('utf-8')

    # 3. Prepara a requisição HTTP POST
    req = urllib.request.Request(
        API_URL,
        data=data_bytes,
        method='POST'
    )

    # Define o cabeçalho Content-Type para informar à API que o corpo é JSON
    req.add_header('Content-Type', 'application/json')
    req.add_header('Accept', 'application/json')

    # 4. Envia a requisição e trata a resposta
    try:
        with urllib.request.urlopen(req) as response:
            # Lê o corpo da resposta
            response_body = response.read().decode('utf-8')

            # Tenta converter o corpo da resposta em JSON
            try:
                response_json = json.loads(response_body)
            except json.JSONDecodeError:
                # Se não for JSON, retorna a string literal
                response_json = {"message": "Resposta recebida com sucesso, mas não é JSON.", "data": response_body}

            return {
                'statusCode': response.status,
                'body': json.dumps(response_json)
            }

    except urllib.error.HTTPError as e:
        # Trata erros de status HTTP (4xx ou 5xx)
        error_body = e.read().decode('utf-8')
        try:
            error_json = json.loads(error_body)
        except json.JSONDecodeError:
            error_json = {"message": "Erro HTTP da API", "details": error_body}

        print(f"Erro HTTP {e.code}: {error_body}")
        return {
            'statusCode': e.code,
            'body': json.dumps(error_json)
        }

    except urllib.error.URLError as e:
        # Trata erros de URL (ex: falha de DNS, problema de rede)
        print(f"Erro de URL ou rede: {e.reason}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Falha na conexão com a API', 'error_details': str(e.reason)})
        }

    except Exception as e:
        # Trata outros erros inesperados
        print(f"Erro inesperado: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro interno na função Lambda', 'error_details': str(e)})
        }
