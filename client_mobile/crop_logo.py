from PIL import Image

def crop_to_teal(input_path, output_path):
    img = Image.open(input_path).convert("RGB")
    data = img.getdata()
    width, height = img.size
    
    min_x = width
    min_y = height
    max_x = 0
    max_y = 0
    
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            # Teal is roughly high G and B, low R. Let's say R < 100, G > 100, B > 100
            # Let's just look for anything non-white and non-black.
            # Actually, the text is also teal! We only want the top teal square.
            # Let's find the first row with teal, and the last row with teal before a huge white gap.
            pass

# Simpler: Just get the bounding box of the continuous non-white region at the top
    # Let's just find the bounding box of ALL non-white pixels, then cut off the bottom text.
    # Usually text is in the bottom 20%. Let's crop the bottom 25% out before finding bounding box!
    
    for y in range(int(height * 0.8)):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            if not (r > 240 and g > 240 and b > 240):
                if x < min_x: min_x = x
                if x > max_x: max_x = x
                if y < min_y: min_y = y
                if y > max_y: max_y = y

    if min_x < max_x and min_y < max_y:
        # add a small padding
        padding = 10
        min_x = max(0, min_x - padding)
        min_y = max(0, min_y - padding)
        max_x = min(width, max_x + padding)
        max_y = min(height, max_y + padding)
        
        cropped = img.crop((min_x, min_y, max_x, max_y))
        
        # Make it square
        cw = max_x - min_x
        ch = max_y - min_y
        size = max(cw, ch)
        
        # Create a new image with teal background? No, let's just make it transparent padding or keep the teal
        # Actually the teal is rounded. Let's just create a transparent square and paste the cropped image in the center.
        new_img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
        offset_x = (size - cw) // 2
        offset_y = (size - ch) // 2
        new_img.paste(cropped, (offset_x, offset_y))
        new_img.save(output_path, "PNG")
        print(f"Cropped to {cw}x{ch}")
    else:
        print("Could not find logo")

crop_to_teal('assets/logo.jpg', 'assets/logo_icon.png')
