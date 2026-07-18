import urllib.request
import json
try:
    req = urllib.request.Request('https://qubahom.com/api/v1/auth/login', data=b'', headers={'User-Agent': 'Mozilla/5.0'})
    res = urllib.request.urlopen(req)
    print('STATUS', res.status)
except Exception as e:
    print('ERROR', e)
