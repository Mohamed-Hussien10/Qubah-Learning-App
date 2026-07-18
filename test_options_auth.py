import urllib.request
try:
    req = urllib.request.Request('https://qubahom.com/api/v1/auth/login', method='OPTIONS', headers={'Origin': 'http://localhost:5000', 'Access-Control-Request-Method': 'POST', 'Access-Control-Request-Headers': 'authorization, content-type, accept'})
    res = urllib.request.urlopen(req)
    print('OPTIONS STATUS', res.status)
    print('OPTIONS HEADERS', res.headers)
except Exception as e:
    print('ERROR OPTIONS', e)
    if hasattr(e, 'headers'):
        print('ERROR HEADERS', e.headers)
