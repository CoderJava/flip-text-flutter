#!/usr/bin/env python3
"""Generate premium Flip Text app icon - minimal & modern."""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math

OUT_DIR = "/Users/yudisetiawan/AndroidStudioProjects/flip_text/playstore_screenshots"

def find_font():
    c = ["/System/Library/Fonts/Helvetica.ttc", "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
         "/System/Library/Fonts/Supplemental/Arial.ttf", "/System/Library/Fonts/SFNSDisplay.ttf"]
    for fp in c:
        if os.path.exists(fp): return fp
    for r, d, f in os.walk("/System/Library/Fonts"):
        for fn in f:
            if fn.endswith(('.ttc','.ttf')): return os.path.join(r, fn)
    return None

def create_logo(size=1024):
    s = size
    img = Image.new('RGBA', (s, s), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    p1, p2, p3 = (108,99,255), (99,89,255), (78,207,180)
    
    # Background gradient (purple to teal)
    for y in range(s):
        t = y / s
        r = int(p1[0] + (p3[0]-p1[0])*t)
        g = int(p1[1] + (p3[1]-p1[1])*t)
        b = int(p1[2] + (p3[2]-p1[2])*t)
        draw.line([(0,y),(s,y)], fill=(r,g,b,255))
    
    # Rounded square badge (darker)
    bm = int(s*0.12)
    br = int(s*0.22)
    badge = Image.new('RGBA', (s,s), (0,0,0,0))
    bd = ImageDraw.Draw(badge)
    for y in range(bm, s-bm):
        t = (y-bm)/(s-2*bm)
        r = int(p2[0] + (80-p2[0])*t)
        g = int(p2[1] + (70-p2[1])*t)
        b = int(p2[2] + (200-p2[2])*t)
        bd.line([(bm,y),(s-bm,y)], fill=(r,g,b,255))
    # Mask
    mask = Image.new('L', (s,s), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([bm,bm,s-bm,s-bm], radius=br, fill=255)
    badge.putalpha(mask)
    img = Image.alpha_composite(img, badge)
    
    # White inner border
    draw = ImageDraw.Draw(img)
    ib = bm + int(s*0.025)
    draw.rounded_rectangle([ib,ib,s-ib,s-ib], radius=br-int(s*0.02), 
                          outline=(255,255,255,35), width=max(2, s//180))
    
    # Font
    fp = find_font()
    ls = int(s*0.22)
    font = ImageFont.truetype(fp, ls) if fp else ImageFont.load_default()
    
    # "a" normal
    ab = draw.textbbox((0,0), "a", font=font)
    aw, ah = ab[2]-ab[0], ab[3]-ab[1]
    
    # "b" on separate canvas to flip
    bp = int(s*0.04)
    bc = Image.new('RGBA', (int(aw*1.4)+bp*2, int(ah*1.5)+bp*2), (0,0,0,0))
    bd2 = ImageDraw.Draw(bc)
    bb = bd2.textbbox((0,0), "b", font=font)
    bw, bh = bb[2]-bb[0], bb[3]-bb[1]
    bcx = (bc.size[0]-bw)//2 - bb[0]
    bcy = (bc.size[1]-bh)//2 - bb[1]
    bd2.text((bcx, bcy), "b", font=font, fill=(255,255,255,255))
    bf = bc.transpose(Image.FLIP_TOP_BOTTOM)
    
    # Layout
    sp = int(s*0.04)
    tw = aw + sp + bw
    cx = (s-tw)//2
    cy = int(s*0.40)
    
    draw.text((cx-ab[0], cy-ab[1]), "a", font=font, fill=(255,255,255,255))
    
    bx2 = cx + aw + sp - bb[0]
    by2 = cy - bb[1] + ah - bh
    img.paste(bf, (bx2-bp, by2-bp), bf)
    
    # "FLIP TEXT" label
    ss = int(s*0.055)
    fs = ImageFont.truetype(fp, ss) if fp else ImageFont.load_default()
    st = "FLIP TEXT"
    sb2 = draw.textbbox((0,0), st, font=fs)
    sw, sh = sb2[2]-sb2[0], sb2[3]-sb2[1]
    sx = (s-sw)//2 - sb2[0]
    sy = int(s*0.59)
    draw.text((sx, sy), st, font=fs, fill=(255,255,255,220))
    
    # Decorative dots
    dr = int(s*0.01)
    dby = int(s*0.70)
    for dx in [-int(s*0.05), int(s*0.05)]:
        dcx = s//2 + dx
        draw.ellipse([dcx-dr, dby-dr, dcx+dr, dby+dr], fill=(255,255,255,100))
    
    # Subtle vignette
    v = Image.new('RGBA', (s,s), (0,0,0,0))
    vd = ImageDraw.Draw(v)
    cx2, cy2 = s//2, s//2
    for y in range(s):
        for x in range(0, s, 3):
            dx, dy = x-cx2, y-cy2
            d = math.sqrt(dx*dx+dy*dy)
            a = max(0, min(60, int(60*(d/(s*0.7)-0.4))))
            if a > 0: vd.point((x,y), fill=(0,0,0,a))
            if x+1 < s: vd.point((x+1,y), fill=(0,0,0,a))
            if x+2 < s: vd.point((x+2,y), fill=(0,0,0,a))
    img = Image.alpha_composite(img, v)
    
    return img

# Generate
for sz, fn, desc in [(1024,"logo_1024.png","High-res"), (512,"logo_512.png","Store"), (192,"logo_192.png","Adaptive")]:
    logo = create_logo(sz)
    fp = os.path.join(OUT_DIR, fn)
    logo.save(fp, "PNG")
    print(f"✅ {fn} ({sz}x{sz}) - {os.path.getsize(fp):,}B - {desc}")
print(f"\nLocation: {OUT_DIR}")
