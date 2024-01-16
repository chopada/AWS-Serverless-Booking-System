const AWS = require('aws-sdk');

// Create a DynamoDB Document Client
const dynamodb = new AWS.DynamoDB.DocumentClient();

// Specify the table name
const tableName = process.env.DYNAMODB_TABLE_NAME;

const hashkey = process.env.DYNAMODB_HASH_KEY;
const rangekey = process.env.DYNAMODB_RANGE_KEY;
exports.lambda_handler = async (event) => {
    try {
        // Extract the hash key value from the event or provide it directly
        const queryParams = event.queryStringParameters || {};
        const rangeKeyValue = queryParams.userid || null;
        const hashKeyValue = queryParams.showid || null;

        // Define the parameters for the query operation
        const params = {
            TableName: tableName,
            Key: {
                [hashkey]: hashKeyValue,
                [rangekey]: rangeKeyValue
            }
        };

        // Perform the get operation
        const data = await dynamodb.get(params).promise();

        // Check if the item exists
        if (data.Item) {
            console.log('Item exists:', data.Item);
            return {
                statusCode: 200,
                body: JSON.stringify({ exists: true, item: data.Item }),
            };
        } else {
            console.log('Item does not exist');
            return {
                statusCode: 404,
                body: JSON.stringify({ exists: false }),
            };
        }
    } catch (error) {
        console.error('Error checking item existence:', error);

        // Return an error response
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Internal Server Error' }),
        };
    }
};