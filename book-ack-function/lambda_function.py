import json

def lambda_handler(event, context):
    # Assuming the query parameters are present in the 'queryStringParameters' field
    query_params = event.get('queryStringParameters', {})

    # Extracting values for ID and count
    id_value = query_params.get('id', None)
    count_value = query_params.get('count', None)

    # Returning a response with extracted values
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'id': id_value,
            'count': count_value
        })
    }

    return response
