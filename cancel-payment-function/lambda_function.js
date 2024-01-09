const AWS = require('aws-sdk');


// Create an SQS service object
const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();


exports.lambda_handler = async (event, context) => {
    try {
        console.log("event::", event);
        // Perform your message processing logic here
        for (const record of event.Records) {
            const { body, messageAttributes, receiptHandle } = record;

            console.log('Body:', body);
            console.log('Attributes:', messageAttributes);
            console.log('Receipt Handle:', receiptHandle);

            const id = messageAttributes.id.stringValue;
            const count = messageAttributes.count.stringValue;
            console.log('ID:', id);
            console.log('Count:', count);
            // Your processing logic goes here

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
