import os
from PIL import Image, ImageFilter

assets_dir = "/Users/Hugotestas/flyxy/documentation/design/UI/assets/"
out_dir = os.path.join(assets_dir, "app_store_ipad")

if not os.path.exists(out_dir):
    os.makedirs(out_dir)

target_size = (2048, 2732)

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
                background.paste(img, mask=img.split()[3])
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
                
            # Create a blurred background to fill the iPad aspect ratio
            # First scale and crop to 2048x2732
            bg_aspect = target_size[0] / target_size[1]
            img_aspect = img.width / img.height
            
            if img_aspect > bg_aspect:
                # Image is wider than background, crop sides
                new_width = int(img.height * bg_aspect)
                left = (img.width - new_width) // 2
                crop_box = (left, 0, left + new_width, img.height)
            else:
                # Image is taller than background, crop top/bottom
                new_height = int(img.width / bg_aspect)
                top = (img.height - new_height) // 2
                crop_box = (0, top, img.width, top + new_height)
                
            bg = img.crop(crop_box).resize(target_size, Image.Resampling.LANCZOS)
            bg = bg.filter(ImageFilter.GaussianBlur(radius=50))
            
            # Now resize the foreground image to fit the height of the iPad
            # iPhone aspect ratio is taller, so height will be the limiting factor
            fg_height = target_size[1]
            fg_width = int(img.width * (fg_height / img.height))
            fg = img.resize((fg_width, fg_height), Image.Resampling.LANCZOS)
            
            # Add a subtle drop shadow to the foreground
            # (To keep it simple and clean, we just paste it directly, or with a slight margin)
            
            # Optional: Add a margin so it looks like a device mockup
            fg_height_with_margin = int(target_size[1] * 0.9)
            fg_width_with_margin = int(img.width * (fg_height_with_margin / img.height))
            fg = img.resize((fg_width_with_margin, fg_height_with_margin), Image.Resampling.LANCZOS)
            
            paste_x = (target_size[0] - fg_width_with_margin) // 2
            paste_y = (target_size[1] - fg_height_with_margin) // 2
            
            bg.paste(fg, (paste_x, paste_y))
            
            out_path = os.path.join(out_dir, filename)
            bg.save(out_path, 'PNG')
            print(f"Processed iPad: {filename}")
            
        except Exception as e:
            print(f"Error processing {filename}: {e}")

print("Done processing iPad screenshots.")
