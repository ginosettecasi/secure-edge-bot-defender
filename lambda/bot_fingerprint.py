import json
import re

def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    headers = request['headers']
    flagged = False
    reasons = []

    def header(name):
        return headers.get(name.lower(), [{'value': ''}])[0]['value']

    user_agent = header('user-agent')
    accept_lang = header('accept-language')
    referer = header('referer')

    # 🚩 1. Missing common headers
    if not accept_lang:
        flagged = True
        reasons.append("Missing Accept-Language header")
    if not referer:
        flagged = True
        reasons.append("Missing Referer header")

    # 🚩 2. Suspicious User-Agent
    if not re.search(r"(Mozilla|Chrome|Safari|Firefox)", user_agent, re.I):
        flagged = True
        reasons.append(f"Unusual User-Agent: {user_agent}")

    # 🚩 3. Headless browser indicators
    if "headless" in user_agent.lower():
        flagged = True
        reasons.append("Headless browser detected")

    # ✅ Add custom header so WAF can block flagged traffic
    if flagged:
        request['headers']['x-suspicious-bot'] = [{'key': 'x-suspicious-bot', 'value': 'true'}]
        print(f"[BLOCK] Bot-like request flagged: {json.dumps(reasons)}")
    else:
        request['headers']['x-suspicious-bot'] = [{'key': 'x-suspicious-bot', 'value': 'false'}]
        print("[ALLOW] Legitimate request passed")

    return request
