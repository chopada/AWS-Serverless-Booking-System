const AWS = require('aws-sdk');

const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();

exports.lambda_handler = async (event, context) => {
    try {
        // Assuming the query parameters are present in the 'queryStringParameters' field
        const queryParams = event.queryStringParameters || {};
        console.log("Lambda function started....")
        // Extracting values for ID and count
        const idValue = queryParams.id || null;
        const countValue = queryParams.count || null;

        // Validating count as a number

        //countValue = parseInt(countValue, 10);
        if (isNaN(countValue)) {
            throw new Error('Invalid count parameter. Count must be a valid number.');
        }


        const messageBody = {
            id: idValue,
            count: countValue,
        };

        // Sending the message to SQS

        await sqsClient.sendMessage({
            QueueUrl: sqsQueueUrl,
            MessageBody: JSON.stringify(messageBody),
        }).promise();

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
    }
    catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                error,
            }),
        };
    }

};
