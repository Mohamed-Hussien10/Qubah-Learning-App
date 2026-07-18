import urllib.request
import json
try:
    req = urllib.request.Request('https://qubahom.com/api/v1/auth/login', data=b'{"email":"admin@gmail.com","password":"password"}', headers={'User-Agent': 'Mozilla/5.0', 'Content-Type': 'application/json', 'Accept': 'application/json'})
    res = urllib.request.urlopen(req)
    print('STATUS', res.status)
    print('HEADERS', res.headers)
    print('BODY', res.read().decode('utf-8')[:200])
except Exception as e:
    print('ERROR', e)
    if hasattr(e, 'headers'):
        print('ERROR HEADERS', e.headers)
    if hasattr(e, 'read'):
        print('ERROR BODY', e.read().decode('utf-8')[:200])
