import sys
from PIL import Image, ImageFilter

if len(sys.argv) < 3:
    print("Usage: make_transparent.py <input> <output>")
    sys.exit(1)

def process_image(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    # Create a mask: 255 = opaque (keep), 0 = transparent (remove)
    mask = Image.new("L", (width, height), 255)
    
    pixels = img.load()
    mask_pixels = mask.load()
    
    visited = set()
    seeds = [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)]
    
    # Tolerance for background detection (pixels with RGB < 25)
    def is_background(x, y):
        r, g, b, _ = pixels[x, y]
        return r < 25 and g < 25 and b < 25

    queue = []
    for seed in seeds:
        if is_background(*seed):
            queue.append(seed)
            visited.add(seed)
            mask_pixels[seed[0], seed[1]] = 0
            
    # Flood-fill BFS to mark all connected background pixels
    while queue:
        cx, cy = queue.pop(0)
        for dx, dy in [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (-1,1), (1,-1), (1,1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited and is_background(nx, ny):
                    visited.add((nx, ny))
                    mask_pixels[nx, ny] = 0
                    queue.append((nx, ny))
                    
    # Blur the mask slightly to create a smooth, anti-aliased edge
    blurred_mask = mask.filter(ImageFilter.GaussianBlur(1.2))
    
    # Apply the blurred mask to the image's alpha channel
    r, g, b, _ = img.split()
    final_img = Image.merge("RGBA", (r, g, b, blurred_mask))
    
    final_img.save(output_path, "PNG")
    print("Successfully processed anti-aliased transparent icon!")

process_image(sys.argv[1], sys.argv[2])
