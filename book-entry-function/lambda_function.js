const AWS = require('aws-sdk');

const sqsQueueUrl = process.env.QUEUE_URL
const dynamoDB_Table_NAME = process.env.DYNAMODB_TABLE_NAME
const dynamoDB_Hash_Key = process.env.DYNAMODB_HASH_KEY
const dynamoDB_Range_Key = process.env.DYNAMODB_RANGE_KEY
const dynamoDB = new AWS.DynamoDB.DocumentClient();
const sqsClient = new AWS.SQS();
async function addUser(user_id_params, show_id_params) {
    try {
        console.log(dynamoDB_Table_NAME);
        console.log(dynamoDB_Hash_Key);
        console.log(dynamoDB_Range_Key);
        const params = {
            TableName: dynamoDB_Table_NAME,

            Item: {
                [dynamoDB_Range_Key]: user_id_params,
                [dynamoDB_Hash_Key]: show_id_params
            }
        };

        const result = await dynamoDB.put(params).promise();

        console.log('Item added successfully:', result);
        return true;
    } catch (error) {
        console.error('Error adding item:', error);
        return false;
    }
}

exports.lambda_handler = async (event) => {
    try {
        console.log("event::", event);
        console.log("book entry function working")
        // Perform your message processing logic here
        console.log(event.Records[0].attributes);
        for (const record of event.Records) {
            const bodyObject = JSON.parse(record.body);
            const user_id = bodyObject.MessageAttributes.userid.Value;
            const show_id = bodyObject.MessageAttributes.showid.Value;
            const addUserResult = await addUser(user_id, show_id);
            if (!addUserResult) {
                throw new Error("Not Update Successfully");
            }
            else {
                console.log("User Added Successfully");
                await deleteMessage(record.receiptHandle, sqsQueueUrl);
            }
        }

    } catch (error) {
        console.error('Error creating item in DynamoDB:', error);
        return {
            statusCode: 500,
            body: JSON.stringify('Error creating item in DynamoDB'),
        };
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
