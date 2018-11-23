exports.handler = (event, context, callback) => {
  const response = {
    statusCode: 200,
    isBase64Encoded: false,
    headers: {
      'content-type': 'application/json',
    },
    body: JSON.stringify(event.path),
  };
  console.log('event', event)
  callback(null, response);
};
