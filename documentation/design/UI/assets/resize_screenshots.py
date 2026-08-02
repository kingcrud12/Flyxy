import os
from PIL import Image

assets_dir = "/Users/Hugotestas/flyxy/documentation/design/UI/assets/"
out_dir = os.path.join(assets_dir, "app_store_6.9_inch")

if not os.path.exists(out_dir):
    os.makedirs(out_dir)

target_size = (1320, 2868)

for filename in os.listdir(assets_dir):
    if filename.startswith("Simulator Screenshot") and filename.endswith(".png"):
        filepath = os.path.join(assets_dir, filename)
        try:
            img = Image.open(filepath)
            
            # Remove alpha channel if present
            if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[3]) # 3 is the alpha channel
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
                
            # Resize
            img_resized = img.resize(target_size, Image.Resampling.LANCZOS)
            
            out_path = os.path.join(out_dir, filename)
            img_resized.save(out_path, 'PNG')
            print(f"Processed: {filename}")
            
        except Exception as e:
            print(f"Error processing {filename}: {e}")

print("Done processing screenshots.")
