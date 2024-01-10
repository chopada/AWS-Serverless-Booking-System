const AWS = require('aws-sdk');
const { error } = require('console');

const sqsQueueUrl = process.env.QUEUE_URL
const dynamoDB_Admin_Table = process.env.DYNAMODB_TABLE_NAME_ADMIN
const dynamoDB_User_Table = process.env.DYNAMODB_TABLE_NAME_USER
const dynamoDB = new AWS.DynamoDB.DocumentClient();
async function updateShowData(user_id_params, show_id_params) {
    try {
        // Admin Side Data Update
        const showId = show_id_params;
        const newBookedUser = {
            user_id: user_id_params
        };
        const updateExpression = 'SET #bu = list_append(if_not_exists(#bu, :empty_list), :new_user)';
        const expressionAttributeNames = { '#bu': 'booked_users', '#tc': 'Ticket_Count' };
        const expressionAttributeValues = {
            ':empty_list': [],
            ':new_user': [newBookedUser],
            ':decrement': 1
        };
        // Decrease ticket_count by 1 if it's greater than 0
        updateExpression += ' ADD #tc :decrement';


        const result = await dynamoDB.update({
            TableName: dynamoDB_Admin_Table,
            Key: { SHOW_ID: showId },
            UpdateExpression: updateExpression,
            ExpressionAttributeNames: expressionAttributeNames,
            ExpressionAttributeValues: expressionAttributeValues,
            ConditionExpression: 'attribute_exists(#tc) AND #tc > :decrement',
            ReturnValues: 'ALL_NEW' // Optional, returns the updated item
        }).promise();

        console.log('Update successful:', result);
        return true;
    } catch (error) {
        console.error('Error updating show data:', error);
        return false;
    }
}
async function addUser(user_id_params, show_id_params) {
    try {
        const params = {
            TableName: dynamoDB_User_Table,
            Item: {
                user_id: user_id_params,
                show_id: show_id_params
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
            console.log(user_id);
            console.log(show_id);
            console.log("Working GOod");
            const updateAdminResult = await updateShowData(user_id, show_id);
            const addUserResult = await addUser(user_id, show_id);
            if (!updateAdminResult && !addUserResult) {
                throw new Error("Not Update Successfully");
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