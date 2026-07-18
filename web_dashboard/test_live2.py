import urllib.request
import json

url2 = "https://qubahom.com/api/v1/free-trial/stages/1/grades"
req2 = urllib.request.Request(url2, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req2, timeout=10) as response2:
        grades_data = json.loads(response2.read().decode())
        
        with open("live_output_2.txt", "w", encoding="utf-8") as f:
            f.write("GRADES:\n")
            f.write(json.dumps(grades_data, indent=2, ensure_ascii=False))
            
            if grades_data.get('data'):
                first_grade_id = grades_data['data'][0]['id']
                f.write(f"\n\nFETCHING SUBJECTS FOR GRADE {first_grade_id}...\n")
                url3 = f"https://qubahom.com/api/v1/free-trial/grades/{first_grade_id}/subjects"
                req3 = urllib.request.Request(url3, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req3, timeout=10) as response3:
                    subjects_data = json.loads(response3.read().decode())
                    f.write(json.dumps(subjects_data, indent=2, ensure_ascii=False))
                    
                    if subjects_data.get('data'):
                        first_subject_id = subjects_data['data'][0]['id']
                        f.write(f"\n\nFETCHING LESSON FILES FOR SUBJECT {first_subject_id}...\n")
                        url4 = f"https://qubahom.com/api/v1/free-trial/subjects/{first_subject_id}/lesson-files"
                        req4 = urllib.request.Request(url4, headers={'User-Agent': 'Mozilla/5.0'})
                        with urllib.request.urlopen(req4, timeout=10) as response4:
                            files_data = json.loads(response4.read().decode())
                            f.write(json.dumps(files_data, indent=2, ensure_ascii=False))
except Exception as e:
    with open("live_output_2.txt", "w", encoding="utf-8") as f:
        f.write(f"Error: {e}")
