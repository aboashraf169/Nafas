"""
Generate the Nafas app icon (1024x1024 PNG).
A soft, glowing orb on a deep navy background — visually matches the in-app BreathOrb.
"""
from PIL import Image, ImageDraw, ImageFilter
import os

SIZE = 1024
OUT = os.path.join(
    os.path.dirname(__file__), "..",
    "Nafas", "Resources", "Assets.xcassets", "AppIcon.appiconset", "AppIcon-1024.png"
)

# -------- background: deep navy with a subtle radial wash --------
img = Image.new("RGB", (SIZE, SIZE), (8, 11, 28))

# Soft purple wash bottom-right
wash = Image.new("RGB", (SIZE, SIZE), (8, 11, 28))
wdraw = ImageDraw.Draw(wash)
wdraw.ellipse(
    [SIZE * 0.25, SIZE * 0.30, SIZE * 1.10, SIZE * 1.15],
    fill=(40, 24, 80)
)
wash = wash.filter(ImageFilter.GaussianBlur(180))
img = Image.blend(img, wash, 0.85)

# -------- outer halo: very large soft circle --------
halo = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
hdraw = ImageDraw.Draw(halo)
for r, a in [(520, 18), (430, 28), (360, 42)]:
    hdraw.ellipse(
        [SIZE/2 - r, SIZE/2 - r, SIZE/2 + r, SIZE/2 + r],
        fill=(140, 170, 255, a)
    )
halo = halo.filter(ImageFilter.GaussianBlur(50))
img.paste(halo, (0, 0), halo)

# -------- the orb itself --------
orb_size = 620
orb = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
odraw = ImageDraw.Draw(orb)

# Base gradient: sky-blue → indigo, top-left to bottom-right.
# Approximation by painting concentric ellipses with shifting color.
top_color    = (125, 211, 252)   # sky-300
bottom_color = (129, 140, 248)   # indigo-400

# Solid orb first
odraw.ellipse([0, 0, orb_size, orb_size], fill=(*bottom_color, 255))

# Now layer top-left highlight gradient
hl = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
hldraw = ImageDraw.Draw(hl)
hldraw.ellipse(
    [-orb_size * 0.15, -orb_size * 0.20, orb_size * 0.95, orb_size * 0.90],
    fill=(*top_color, 255)
)
hl = hl.filter(ImageFilter.GaussianBlur(80))
orb.alpha_composite(hl)

# Mask to keep it perfectly circular
mask = Image.new("L", (orb_size, orb_size), 0)
mdraw = ImageDraw.Draw(mask)
mdraw.ellipse([0, 0, orb_size, orb_size], fill=255)
clean_orb = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
clean_orb.paste(orb, (0, 0), mask)

# Inner glassy highlight (top-left)
gloss = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
gdraw = ImageDraw.Draw(gloss)
gdraw.ellipse(
    [orb_size * 0.10, orb_size * 0.06, orb_size * 0.60, orb_size * 0.50],
    fill=(255, 255, 255, 110)
)
gloss = gloss.filter(ImageFilter.GaussianBlur(40))
gloss_clipped = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
gloss_clipped.paste(gloss, (0, 0), mask)
clean_orb.alpha_composite(gloss_clipped)

# Outer rim highlight
rim = Image.new("RGBA", (orb_size, orb_size), (0, 0, 0, 0))
rdraw = ImageDraw.Draw(rim)
rdraw.ellipse([4, 4, orb_size - 4, orb_size - 4], outline=(255, 255, 255, 40), width=3)
clean_orb.alpha_composite(rim)

# Drop shadow under orb
shadow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
sdraw = ImageDraw.Draw(shadow)
sdraw.ellipse(
    [(SIZE - orb_size) / 2 + 10,
     (SIZE - orb_size) / 2 + 40,
     (SIZE + orb_size) / 2 + 10,
     (SIZE + orb_size) / 2 + 40],
    fill=(125, 211, 252, 90)
)
shadow = shadow.filter(ImageFilter.GaussianBlur(60))
img_rgba = img.convert("RGBA")
img_rgba.alpha_composite(shadow)

# Composite the orb centered
ox = (SIZE - orb_size) // 2
oy = (SIZE - orb_size) // 2
img_rgba.alpha_composite(clean_orb, (ox, oy))

# Concentric soft rings around the orb (the breathing rings)
rings = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
rdraw = ImageDraw.Draw(rings)
for extra, alpha in [(40, 50), (90, 30), (150, 18)]:
    r = orb_size / 2 + extra
    rdraw.ellipse(
        [SIZE/2 - r, SIZE/2 - r, SIZE/2 + r, SIZE/2 + r],
        outline=(180, 200, 255, alpha),
        width=2
    )
rings = rings.filter(ImageFilter.GaussianBlur(0.5))
img_rgba.alpha_composite(rings)

# Final flatten to RGB (App Store icons must not have alpha)
final = Image.new("RGB", (SIZE, SIZE), (8, 11, 28))
final.paste(img_rgba, (0, 0), img_rgba)
final.save(OUT, "PNG", optimize=True)
print(f"Wrote {OUT}")
