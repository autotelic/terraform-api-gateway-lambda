const url = require('url');
const https = require('https');

let hookUrl;

const postMessage = (message, callback) => {
  const body = JSON.stringify(message);
  const options = url.parse(hookUrl);
  options.method = 'POST';
  options.headers = {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
  };

  const postReq = https.request(options, (res) => {
    const chunks = [];
    res.setEncoding('utf8');
    res.on('data', chunk => chunks.push(chunk));
    res.on('end', () => {
      const body = chunks.join('');
      if (callback) {
        callback({
          body,
          statusCode: res.statusCode,
          statusMessage: res.statusMessage,
        });
      }
    });
    return res;
  });

  postReq.write(body);
  postReq.end();
};

const handleCloudWatch = (event) => {
  const timestamp = (new Date(event.Records[0].Sns.Timestamp)).getTime() / 1000;
  const message = JSON.parse(event.Records[0].Sns.Message);
  const region = event.Records[0].EventSubscriptionArn.split(':')[3];
  const subject = 'AWS CloudWatch Notification';
  const alarmName = message.AlarmName;
  const metricName = message.Trigger.MetricName;
  const oldState = message.OldStateValue;
  const newState = message.NewStateValue;
  const alarmReason = message.NewStateReason;
  const trigger = message.Trigger;
  let color = 'warning';

  if (message.NewStateValue === 'ALARM') {
    color = 'danger';
  } else if (message.NewStateValue === 'OK') {
    color = 'good';
  }

  return {
    text: `*${subject}*`,
    attachments: [
      {
        color,
        fields: [
          { title: 'Alarm Name', value: alarmName, short: true },
          { title: 'Alarm Description', value: alarmReason, short: false },
          {
            title: 'Trigger',
            value: `${trigger.Statistic} ${
              metricName} ${
              trigger.ComparisonOperator} ${
              trigger.Threshold} for ${
              trigger.EvaluationPeriods} period(s) of ${
              trigger.Period} seconds.`,
            short: false,
          },
          { title: 'Old State', value: oldState, short: true },
          { title: 'Current State', value: newState, short: true },
          {
            title: 'Link to Alarm',
            value: `https://console.aws.amazon.com/cloudwatch/home?region=${region}#alarm:alarmFilter=ANY;name=${alarmName}`,
            short: false,
          },
        ],
        ts: timestamp,
      },
    ],
  };
};

const processEvent = (event, context) => {
  console.log(`sns received:${JSON.stringify(event, null, 2)}`);
  let slackMessage = null;
  const eventSnsMessageRaw = event.Records[0].Sns.Message;
  let eventSnsMessage = null;

  try {
    eventSnsMessage = JSON.parse(eventSnsMessageRaw);
  } catch (e) {
    console.log(e);
  }

  if (eventSnsMessage && 'AlarmName' in eventSnsMessage && 'AlarmDescription' in eventSnsMessage) {
    console.log('processing cloudwatch notification');
    slackMessage = handleCloudWatch(event, context);
  }

  postMessage(slackMessage, (response) => {
    if (response.statusCode < 400) {
      console.info('message posted successfully');
      context.succeed();
    } else if (response.statusCode < 500) {
      console.error(`error posting message to slack API: ${response.statusCode} - ${response.statusMessage}`);
      // Don't retry because the error is due to a problem with the request
      context.succeed();
    } else {
      // Let Lambda retry
      context.fail(`server error when processing message: ${response.statusCode} - ${response.statusMessage}`);
    }
  });
};

exports.handler = (event, context) => {
  console.log(event);
  if (hookUrl) {
    processEvent(event, context);
  } else if (process.env.UNENCRYPTED_HOOK_URL) {
    hookUrl = process.env.UNENCRYPTED_HOOK_URL;
    processEvent(event, context);
  } else {
    context.fail('hook url has not been set.');
  }
};
