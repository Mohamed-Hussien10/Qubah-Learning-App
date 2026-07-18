import re

with open('web_dashboard/lib/core/constants/api_endpoints.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace domainUrl
content = re.sub(
    r'static String get domainUrl \{[\s\S]*?\}',
    r"static String get domainUrl {\n    return 'https://qubahom.com';\n  }",
    content
)

# Replace baseUrl to add trailing slash
content = content.replace("baseUrl => '$domainUrl/api/v1';", "baseUrl => '$domainUrl/api/v1/';")

# Remove leading slashes from endpoints
content = re.sub(r"=\s*'/([^']+)';", r"= '\1';", content)
content = re.sub(r"=>\s*'/([^']+)';", r"=> '\1';", content)

with open('web_dashboard/lib/core/constants/api_endpoints.dart', 'w', encoding='utf-8') as f:
    f.write(content)
