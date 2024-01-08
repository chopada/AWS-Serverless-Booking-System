const AWS = require('aws-sdk');

const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();

exports.lambda_handler = async (event, context) => {
    // Assuming the query parameters are present in the 'queryStringParameters' field
    const queryParams = event.queryStringParameters || {};

    // Extracting values for ID and count
    const idValue = queryParams.id || null;
    let countValue = queryParams.count || null;

    // Validating count as a number
    try {
        countValue = parseInt(countValue, 10);
        if (isNaN(countValue)) {
            throw new Error();
        }
    } catch (error) {
        // Handling the exception if count is not a valid number
        return {
            statusCode: 400,
            body: JSON.stringify({
                error: 'Invalid count parameter. Count must be a number.',
            }),
        };
    }

    const messageBody = {
        id: idValue,
        count: countValue,
    };

    // Sending the message to SQS
    try {
        await sqsClient.sendMessage({
            QueueUrl: sqsQueueUrl,
            MessageBody: JSON.stringify(messageBody),
        }).promise();
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Failed to send message to SQS queue.',
            }),
        };
    }

    // Returning a response with extracted values
    const response = {
        statusCode: 200,
        body: JSON.stringify({
            id: idValue,
            count: countValue,
            message: 'Values sent to SQS queue successfully',
        }),
    };

    return response;
};
