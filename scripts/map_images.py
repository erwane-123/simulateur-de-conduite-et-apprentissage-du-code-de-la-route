import os
import shutil
import re
import glob

brain_dir = r"C:\Users\Romeo\.gemini\antigravity\brain\82a0e8bf-4c7c-49a1-a0f8-2d6c0e10c74d"
project_dir = r"c:\Users\Romeo\projet-2026\code_route_flutter"
images_dest = os.path.join(project_dir, "assets", "images", "questions")
dart_file = os.path.join(project_dir, "lib", "data", "test_questions.dart")

os.makedirs(images_dest, exist_ok=True)

# 1. Copy and rename images
image_mapping = {
    "priority_intersection": "priority_intersection",
    "roundabout_approach": "roundabout_approach",
    "speeding_rain": "speeding_rain",
    "night_driving": "night_driving",
    "pedestrian_crossing": "pedestrian_crossing",
    "dashboard_warning": "dashboard_warning"
}

available_images = []

for base_name in image_mapping.keys():
    matches = glob.glob(os.path.join(brain_dir, f"{base_name}_*.png"))
    if matches:
        src = matches[0]
        dst = os.path.join(images_dest, f"{base_name}.png")
        shutil.copy2(src, dst)
        available_images.append(base_name)
        print(f"Copied {base_name}.png")

# 2. Process dart file
with open(dart_file, 'r', encoding='utf-8') as f:
    content = f.read()

def smart_replace(match):
    block = match.group(0)
    
    # Extract the question text
    q_match = re.search(r'question:\s*"([^"]+)"', block)
    if not q_match:
        return block # Fallback
        
    q_text = q_match.group(1).lower()
    
    assigned_img = available_images[hash(q_text) % len(available_images)] # Default deterministic
    
    # Keyword matching for the 6 available images
    if any(w in q_text for w in ['piéton', 'passage', 'traverser']):
        if 'pedestrian_crossing' in available_images: assigned_img = 'pedestrian_crossing'
    elif any(w in q_text for w in ['nuit', 'phare', 'éblouissant', 'obscur']):
        if 'night_driving' in available_images: assigned_img = 'night_driving'
    elif any(w in q_text for w in ['vitesse', 'pluie', 'autoroute', 'mouillé', 'aquaplaning']):
        if 'speeding_rain' in available_images: assigned_img = 'speeding_rain'
    elif any(w in q_text for w in ['rond-point', 'giratoire', 'anneau']):
        if 'roundabout_approach' in available_images: assigned_img = 'roundabout_approach'
    elif any(w in q_text for w in ['priorité', 'intersection', 'cédez', 'droite', 'croisement']):
        if 'priority_intersection' in available_images: assigned_img = 'priority_intersection'
    elif any(w in q_text for w in ['voyant', 'tableau de bord', 'frein', 'moteur']):
        if 'dashboard_warning' in available_images: assigned_img = 'dashboard_warning'
        
    # Replace the old imagePath with the new one
    new_img_path = f'"assets/images/questions/{assigned_img}.png"'
    new_block = re.sub(r'imagePath:\s*"[^"]+"', f'imagePath: {new_img_path}', block)
    return new_block

# Find question blocks: TestQuestion( ... )
new_content = re.sub(r'TestQuestion\([^)]+\)', smart_replace, content, flags=re.DOTALL)

with open(dart_file, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Updated test_questions.dart with smart image paths!")
