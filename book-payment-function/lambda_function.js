const AWS = require('aws-sdk');


// Create an SQS service object
const sqsQueueUrl = process.env.QUEUE_URL;
const sqsClient = new AWS.SQS();


exports.lambda_handler = async (event, context) => {
    try {
        // Replace 'your-queue-url' with the URL of your SQS queue
        const params = {
            QueueUrl: sqsQueueUrl,
            MaxNumberOfMessages: 1, // Number of messages to retrieve (adjust as needed)
            VisibilityTimeout: 10, // Visibility timeout in seconds (adjust as needed)
            WaitTimeSeconds: 5, // Long polling time (adjust as needed)
        };

        // Fetch messages from the SQS queue
        const data = await sqsClient.receiveMessage(params).promise();

        if (data.Messages) {
            // Process each received message
            for (const message of data.Messages) {
                console.log('Received message:', message.Body);

                // Perform your message processing logic here

                // Delete the processed message from the queue
                await deleteMessage(message.ReceiptHandle, params.QueueUrl);
            }
        } else {
            console.log('No messages received from the queue.');
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
