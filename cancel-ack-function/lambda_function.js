const AWS = require('aws-sdk');

const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();

exports.lambda_handler = async (event, context) => {
    try {
        // Assuming the query parameters are present in the 'queryStringParameters' field
        const queryParams = event.queryStringParameters || {};
        console.log("Lambda function started....")
        // Extracting values for ID and count
        const showid_value = queryParams.showid || null;
        const userid_value = queryParams.userid || null;
        console.log("showid::", showid_value);
        console.log("userid::", userid_value);
        // Validating count as a number

        //countValue = parseInt(countValue, 10);


        const messageAttributes = {
            showid: {
                DataType: 'String',
                StringValue: showid_value.toString(),
            },
            userid: {
                DataType: 'String',
                StringValue: userid_value.toString(),
            },
        };
        const messageBody = {
            showid: showid_value,
            userid: userid_value,
        };
        // Sending the message to SQS

        await sqsClient.sendMessage({
            QueueUrl: sqsQueueUrl,
            MessageAttributes: messageAttributes,
            MessageBody: JSON.stringify(messageBody),
        }).promise();

        // Returning a response with extracted values
        const response = {
            statusCode: 200,
            body: JSON.stringify({
                messageBody: messageBody,
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
