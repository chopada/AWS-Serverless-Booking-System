const AWS = require('aws-sdk');


// Create an SQS service object
const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();
const snsTopicARN = process.env.TOPIC_ARN;
const snsClient = new AWS.SNS();


exports.lambda_handler = async (event, context) => {
    try {
        console.log("event::", event);
        // Perform your message processing logic here
        for (const record of event.Records) {
            const { body, messageAttributes, receiptHandle } = record;

            console.log('Body:', body);
            console.log('Attributes:', messageAttributes);
            console.log('Receipt Handle:', receiptHandle);
            const showid_j = messageAttributes.showid;
            const userid_j = messageAttributes.userid;
            console.log(showid_j);
            console.log(userid_j);
            const showid_value = messageAttributes.showid.stringValue;
            const userid_value = messageAttributes.userid.stringValue;
            console.log('Show ID:', showid_value);
            console.log('User ID:', userid_value);
            // Add Business Logic For payment
            //
            Attributes_SNS = {
                showid: {
                    DataType: 'String',
                    StringValue: showid_value,
                },
                userid: {
                    DataType: 'String',
                    StringValue: userid_value,
                }
            }
            const params = {
                TopicArn: snsTopicARN,
                Message: JSON.stringify(messageAttributes),
                MessageAttributes: Attributes_SNS
            };

            const result = await snsClient.publish(params).promise();
            console.log('Message Send Successfully & Message Id ::', result.MessageId)

            // Delete the processed message from the queue
            await deleteMessage(receiptHandle, sqsQueueUrl);
        }

        return { statusCode: 200, body: 'Messages processed successfully.' };
    } catch (error) {
        console.error('Error:', error);
        return { statusCode: 500, body: 'Error processing messages.' };
    }
};

// Function to delete a message from the SQS queue
async function deleteMessage(receiptHandle, queueUrl) {
    const deleteParams = {
        QueueUrl: queueUrl,
        ReceiptHandle: receiptHandle,
    };

    await sqsClient.deleteMessage(deleteParams).promise();
    console.log('Message deleted from the queue.');
}
