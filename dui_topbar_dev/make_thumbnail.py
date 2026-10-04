# -*- coding: utf-8 -*-
"""Generate a 512x512 Steam Workshop thumbnail for DUI Dynamic Topbar HUD."""
import os
from PIL import Image, ImageDraw, ImageFont

W = H = 512
OUT = r"D:\Local_Mod\Hearts of Iron IV\dui_topbar\thumbnail.png"

# ---------------------------------------------------------------- background
img = Image.new("RGB", (W, H), (13, 19, 27))
d = ImageDraw.Draw(img, "RGBA")
for y in range(H):
    t = y / (H - 1)
    r = int(13 + (25 - 13) * t)
    g = int(19 + (34 - 19) * t)
    b = int(27 + (46 - 27) * t)
    d.line([(0, y), (W, y)], fill=(r, g, b, 255))

# faint map-ish diagonals for texture
for i in range(-H, W, 46):
    d.line([(i, H), (i + H, 0)], fill=(255, 255, 255, 8), width=1)

BAR_H = 58
d.rectangle([0, 0, W, BAR_H], fill=(30, 41, 54, 255))
d.line([(0, BAR_H), (W, BAR_H)], fill=(74, 106, 140, 255), width=2)

ACCENTS = [(216, 164, 74), (108, 176, 230), (126, 200, 140), (214, 96, 96)]


def slot(x, y, accent, digits=2):
    w, h = 92, 28
    d.rectangle([x, y, x + w, y + h], fill=(44, 59, 77, 255), outline=(71, 96, 122, 255))
    d.rectangle([x + 4, y + 4, x + 24, y + 24], fill=accent + (255,))
    bx = x + 30
    for k in range(digits):
        d.rectangle([bx + k * 16, y + 10, bx + k * 16 + 11, y + 18],
                    fill=(240, 245, 250, 235))


# four slots along the top bar (right aligned area)
for i, a in enumerate(ACCENTS):
    slot(300 - i * 96, 15, a, digits=2 if i != 2 else 3)

# "+" add button
cx, cy = 406, 29
d.ellipse([cx - 11, cy - 11, cx + 11, cy + 11], fill=(58, 78, 100, 255), outline=(120, 160, 200, 255))
d.line([(cx - 5, cy), (cx + 5, cy)], fill=(235, 242, 250, 255), width=2)
d.line([(cx, cy - 5), (cx, cy + 5)], fill=(235, 242, 255, 255), width=2)

# ------------------------------------------------------- picker panel mockup
px, py, pw, ph = 288, 74, 200, 122
d.rectangle([px, py, px + pw, py + ph], fill=(24, 33, 45, 245), outline=(90, 126, 164, 255), width=2)
rows = [("政治点", (216, 164, 74)), ("政治偏执度", (214, 96, 96)),
        ("军用工厂", (126, 200, 140)), ("燃料储量", (108, 176, 230))]
try:
    f_small = ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", 15)
except Exception:
    f_small = ImageFont.load_default()
for i, (label, col) in enumerate(rows):
    ry = py + 10 + i * 27
    d.rectangle([px + 10, ry, px + 24, ry + 14], fill=col + (255,))
    d.text((px + 32, ry - 2), label, font=f_small, fill=(226, 236, 246, 255))

# ------------------------------------------------------------------- titles
def load(size, bold=False):
    for p in (r"C:\Windows\Fonts\msyhbd.ttc" if bold else r"C:\Windows\Fonts\msyh.ttc",
              r"C:\Windows\Fonts\msyh.ttc", r"C:\Windows\Fonts\simhei.ttf",
              r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\arial.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            continue
    return ImageFont.load_default()


f_title = load(46, bold=True)
f_sub = load(19)
f_feat = load(18)

d.rectangle([36, 250, 126, 256], fill=(216, 164, 74, 255))
d.text((36, 272), "DUI 动态顶栏 HUD", font=f_title, fill=(245, 249, 253, 255))
d.text((38, 340), "Dynamic Topbar HUD  ·  HOI4 1.19", font=f_sub, fill=(159, 179, 200, 255))
d.text((38, 370), "38 项实时数据，玩家自选", font=f_feat, fill=(207, 224, 239, 255))
d.text((38, 398), "政治偏执度 / 资源 / 工厂 / 人力 …", font=f_feat, fill=(207, 224, 239, 255))
d.text((38, 440), "自适应分辨率 · 随存档保存", font=f_feat, fill=(140, 190, 160, 255))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.save(OUT, "PNG")
print("written:", OUT, os.path.getsize(OUT), "bytes", img.size)
