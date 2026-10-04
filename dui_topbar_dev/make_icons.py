# -*- coding: utf-8 -*-
"""make_icons.py —— 把原版单图标贴图统一成 20x20 的 dui_icon_*.dds + 生成 interface/dui_icons.gfx

动机：原版图标尺寸从 14px 到 30px 不等，直接用在 96x26 的格子里会一大一小。
这里把每个指标选用的原版图标重新采样到统一的 20x20（保持比例、居中、透明背景），
写成 HOI4 支持的未压缩 32bit BGRA DDS，再生成精灵定义。
这样：① 大小完全统一；② 用的仍是原版美术（不用复制黑冰的文件，也就不涉及版权）。
"""
import os
import re
import struct
from PIL import Image

GAME = r'D:\SteamLibrary\steamapps\common\Hearts of Iron IV'
MOD = r'D:\Local_Mod\Hearts of Iron IV\dui_topbar'
OUT = os.path.join(MOD, 'gfx', 'interface', 'dui_icons')
SIZE = 20

# token 后缀 -> 用哪个原版精灵当底稿
SRC = {
    'pp_daily': 'GFX_pol_power',
    'stability': 'GFX_stability_texticon',
    'war_support': 'GFX_war_support_icon',
    'command_power': 'GFX_command_power',
    'paranoia': 'GFX_FOCUS_FILTER_SOV_POLITICAL_PARANOIA',
    'conscription': 'GFX_manpower_texticon',
    'army_manpower': 'GFX_technology_specialization_land',
    'divisions': 'GFX_divisions',
    'battalions': 'GFX_army_shield_bg',
    'planes': 'GFX_technology_specialization_air',
    'ships': 'GFX_technology_specialization_naval',
    'equipment': 'GFX_equipment_icon',
    'casualties': 'GFX_killed_units_icon',
    'surrender': 'GFX_victory_points',
    'warscore': 'GFX_war_score',
    'enemy_strength': 'GFX_in_combat',
    'industry': 'GFX_industry_texticon',
}


def scan_sprites():
    m = {}
    base = os.path.join(GAME, 'interface')
    for root, _dirs, files in os.walk(base):
        for fn in files:
            if not fn.endswith('.gfx'):
                continue
            try:
                t = open(os.path.join(root, fn), 'r', encoding='utf-8', errors='ignore').read()
            except Exception:
                continue
            for blk in re.findall(r'(?:spriteType|corneredTileSpriteType)\s*=\s*\{(.*?)\}', t, re.S):
                n = re.search(r'name\s*=\s*"([^"]+)"', blk)
                f = re.search(r'texture[fF]ile\s*=\s*"([^"]+)"', blk)
                if n and f:
                    m[n.group(1)] = f.group(1)
    return m


def write_dds(img, path):
    """未压缩 32bit BGRA DDS（HOI4 可读）"""
    w, h = img.size
    px = img.convert('RGBA').tobytes()
    bgra = bytearray(len(px))
    bgra[0::4] = px[2::4]
    bgra[1::4] = px[1::4]
    bgra[2::4] = px[0::4]
    bgra[3::4] = px[3::4]
    # DDS 头：magic + dwSize(124) + 7 个 uint32 + reserved[11] + PixelFormat(32) + caps(20) = 128 字节
    hdr = b'DDS ' + struct.pack('<7I', 124, 0x81007, h, w, w * 4, 0, 1) + b'\0' * 44
    hdr += struct.pack('<8I', 32, 0x41, 0, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
    hdr += struct.pack('<5I', 0x1000, 0, 0, 0, 0)
    with open(path, 'wb') as fh:
        fh.write(hdr + bytes(bgra))


def main():
    os.makedirs(OUT, exist_ok=True)
    sp = scan_sprites()
    lines = ['spriteTypes = {', '']
    ok, miss = 0, []
    for key, spr in SRC.items():
        tf = sp.get(spr)
        if not tf:
            miss.append((key, spr, 'sprite not found'))
            continue
        rel = tf.strip().lstrip('/')
        rel = re.sub(r'^gfx[/\\]', '', rel).replace('\\', '/').replace('//', '/')
        p = os.path.join(GAME, 'gfx', rel)
        if not os.path.isfile(p):
            miss.append((key, spr, 'texture missing ' + p))
            continue
        im = Image.open(p).convert('RGBA')
        if im.width > im.height * 2:      # 宽条贴图只取左侧第一个方形
            im = im.crop((0, 0, im.height, im.height))
        im.thumbnail((SIZE, SIZE), Image.LANCZOS)
        canvas = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
        canvas.paste(im, ((SIZE - im.width) // 2, (SIZE - im.height) // 2), im)
        name = 'dui_icon_' + key
        write_dds(canvas, os.path.join(OUT, name + '.dds'))
        lines += ['\tspriteType = {',
                  '\t\tname = "GFX_%s"' % name,
                  '\t\ttexturefile = "gfx/interface/dui_icons/%s.dds"' % name,
                  '\t}']
        ok += 1
    lines.append('}')
    # 注意：HOI4 的 .gfx 不能带 BOM，否则报 "Unexpected token: spriteTypes"
    with open(os.path.join(MOD, 'interface', 'dui_icons.gfx'), 'w', encoding='ascii', newline='\n') as fh:
        fh.write('\n'.join(lines) + '\n')
    print('icons written:', ok, '->', OUT)
    for m in miss:
        print('  MISS', m)


main()
