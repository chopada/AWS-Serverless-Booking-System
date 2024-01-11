const AWS = require('aws-sdk');
const ses = new AWS.SES();

exports.lambda_handler = async (event, context) => {
    console.log("Received event:", JSON.stringify(event, null, 2));

    // Your logic here
    const params = {
        Destination: {
            ToAddresses: ['karanedelta@gmail.com'], // Replace with your recipient email address
        },
        Message: {
            Body: {
                Text: { Data: JSON.stringify(event, null, 2) },
            },
            Subject: { Data: 'Booking System' },
        },
        Source: 'karanedelta@gmail.com', // Replace with your sender email address
    };

    // Send email using SES
    try {
        await ses.sendEmail(params).promise();
        console.log('Email sent successfully.');
    } catch (error) {
        console.error('Error sending email:', error);
    }

    return {
        statusCode: 200,
        body: JSON.stringify("Event logged successfully"),
    };
};
