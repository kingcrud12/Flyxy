from PIL import Image, ImageDraw

def fill_outer_white(input_path, output_path, fill_color):
    img = Image.open(input_path).convert("RGB")
    ImageDraw.floodfill(img, xy=(0, 0), value=fill_color, thresh=50)
    
    # Also floodfill from other corners just in case
    w, h = img.size
    ImageDraw.floodfill(img, xy=(w-1, 0), value=fill_color, thresh=50)
    ImageDraw.floodfill(img, xy=(0, h-1), value=fill_color, thresh=50)
    ImageDraw.floodfill(img, xy=(w-1, h-1), value=fill_color, thresh=50)

    img.save(output_path, "PNG")

fill_outer_white('assets/logo.jpg', 'assets/logo_solid.png', (20, 134, 135))
