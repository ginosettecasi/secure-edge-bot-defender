# lambda/bot_fingerprint.py

def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda Edge Bot Detector!'
    }
