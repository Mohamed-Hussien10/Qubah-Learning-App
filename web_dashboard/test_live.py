import urllib.request
import json

url = "https://qubahom.com/api/v1/free-trial/stages"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10) as response:
        stages_data = json.loads(response.read().decode())
        with open("live_output.txt", "w", encoding="utf-8") as f:
            f.write("STAGES:\n")
            f.write(json.dumps(stages_data, indent=2, ensure_ascii=False))
            
            if stages_data.get('data'):
                first_id = stages_data['data'][0]['id']
                f.write(f"\n\nFETCHING GRADES FOR STAGE {first_id}...\n")
                url2 = f"https://qubahom.com/api/v1/free-trial/stages/{first_id}/grades"
                req2 = urllib.request.Request(url2, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req2, timeout=10) as response2:
                    grades_data = json.loads(response2.read().decode())
                    f.write(json.dumps(grades_data, indent=2, ensure_ascii=False))
except Exception as e:
    with open("live_output.txt", "w", encoding="utf-8") as f:
        f.write(f"Error: {e}")
