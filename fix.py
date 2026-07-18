import re

with open('lib/core/network/api_endpoints.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("baseUrl => '$domainUrl/api/v1';", "baseUrl => '$domainUrl/api/v1/';")
content = re.sub(r"=\s*'/([^']+)';", r"= '\1';", content)
content = re.sub(r"=>\s*'/([^']+)';", r"=> '\1';", content)

with open('lib/core/network/api_endpoints.dart', 'w', encoding='utf-8') as f:
    f.write(content)
