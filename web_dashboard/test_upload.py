import urllib.request
import urllib.parse
import json

url = 'https://qubahom.com/api/v1/thumbnails/upload'
boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW'

body = (
    f'--{boundary}\r\n'
    f'Content-Disposition: form-data; name="folder"\r\n\r\n'
    f'free-trial/stages\r\n'
    f'--{boundary}\r\n'
    f'Content-Disposition: form-data; name="thumbnail"; filename="dummy.jpg"\r\n'
    f'Content-Type: image/jpeg\r\n\r\n'
    f'dummy content\r\n'
    f'--{boundary}--\r\n'
).encode('utf-8')

req = urllib.request.Request(url, data=body, headers={
    'Content-Type': f'multipart/form-data; boundary={boundary}',
    'User-Agent': 'Mozilla/5.0'
})

try:
    with urllib.request.urlopen(req) as response:
        resp_text = response.read().decode('utf-8')
        print("UPLOAD RESPONSE:", response.status, resp_text)
        
        resp_json = json.loads(resp_text)
        path = resp_json['data']['path']
        print("\nAttempting to download via proxy:")
        proxy_url = 'https://qubahom.com/api/v1/' + path
        print(proxy_url)
        
        req2 = urllib.request.Request(proxy_url, headers={'User-Agent': 'Mozilla/5.0'})
        try:
            with urllib.request.urlopen(req2) as proxy_resp:
                print("PROXY RESPONSE:", proxy_resp.status, proxy_resp.read()[:100])
        except urllib.error.HTTPError as e:
            print("PROXY ERROR:", e.code)
except urllib.error.HTTPError as e:
    print("UPLOAD ERROR:", e.code, e.read().decode('utf-8'))
