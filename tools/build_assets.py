#!/usr/bin/env python3
"""Compile original, editable BrenOS vector designs into Windows-ready assets."""
from pathlib import Path
from io import BytesIO
import json, math, struct, wave
import cairosvg
from PIL import Image, ImageDraw, ImageEnhance, ImageOps

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'assets'/'source'
OUT=ROOT/'assets'/'generated'
for name in ('brand','wallpapers','icons/svg','icons/png','icons/ico','cursors','sounds','previews'):
    (OUT/name).mkdir(parents=True,exist_ok=True)

def render(svg,path,px):
    cairosvg.svg2png(bytestring=svg.encode('utf8'),write_to=str(path),
        output_width=px,output_height=px)

logo=(SRC/'brand-mark.svg').read_text(encoding='utf8')
(OUT/'brand'/'Nexus.svg').write_text(logo,encoding='utf8')
for px in (32,64,128,256,512):
    render(logo,OUT/'brand'/f'Nexus-{px}.png',px)
Image.open(OUT/'brand'/'Nexus-512.png').save(OUT/'brand'/'BrenOS.ico',format='ICO',
    sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
(OUT/'brand'/'palette.json').write_text(json.dumps({
    'midnight':'#17273B','slate':'#294C76','electric':'#3B82F6',
    'cyan':'#2DD3EE','steel':'#94A3B8','cloud':'#EAF6FF'},indent=2),encoding='utf8')

imagefile=OUT/'wallpaper.tmp.png'
cairosvg.svg2png(url=str(SRC/'wallpaper.svg'),write_to=str(imagefile),
    output_width=3840,output_height=2160)
base=Image.open(imagefile).convert('RGB')
variants={'Flow':base,'Dawn':ImageEnhance.Brightness(base).enhance(1.11),
          'Midnight':ImageEnhance.Brightness(base).enhance(.76)}
for name,picture in variants.items():
    picture.save(OUT/'wallpapers'/f'BrenOS-{name}.jpg',quality=93)
    for label,size in (('FHD',(1920,1080)),('QHD',(2560,1440)),
                       ('4K',(3840,2160)),('Ultrawide',(3440,1440))):
        if size==picture.size:
            scaled=picture
        else:
            w,h=size
            ratio=max(w/picture.width,h/picture.height)
            resized=picture.resize((round(picture.width*ratio),
                                    round(picture.height*ratio)),Image.Resampling.LANCZOS)
            # Keep glowing orbital mark near right side on wide screens.
            center=min(max(round(resized.width*.54),w//2),resized.width-w//2)
            left=center-w//2
            top=(resized.height-h)//2
            scaled=resized.crop((left,top,left+w,top+h))
        scaled.save(OUT/'wallpapers'/f'BrenOS-{name}-{label}.jpg',quality=90)
base.resize((1920,1080),Image.Resampling.LANCZOS).save(
    OUT/'wallpapers'/'BrenOS-Lock.jpg',quality=93)
imagefile.unlink()

icons=json.loads((SRC/'icons.json').read_text(encoding='utf8'))
assert len(icons)==50 and len({i['name'] for i in icons})==50
for item in icons:
    name,path=item['name'],item['path']
    svg=f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
<defs><linearGradient id="gradient" x1="0" y1="0" x2="1" y2="1">
<stop stop-color="#EAF9FF"/><stop offset=".45" stop-color="#5CC8FF"/>
<stop offset="1" stop-color="#3A79EB"/></linearGradient></defs>
<rect x="3" y="3" width="122" height="122" rx="29"
fill="#223A54" stroke="#7497BC" stroke-width="2"/>
<g transform="translate(14 14) scale(1.55)" fill="none"
stroke="url(#gradient)" stroke-width="3.5" stroke-linecap="round"
stroke-linejoin="round"><path d="{path}"/></g></svg>"""
    (OUT/'icons'/'svg'/f'{name}.svg').write_text(svg,encoding='utf8')
    render(svg,OUT/'icons'/'png'/f'{name}.png',512)
    Image.open(OUT/'icons'/'png'/f'{name}.png').save(
        OUT/'icons'/'ico'/f'{name}.ico',format='ICO',
        sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])

# CUR file format has type=2 plus hotspots; not a renamed PNG.
cursors=('Arrow','Hand','IBeam','Wait','AppStarting','Help','Crosshair',
    'SizeAll','SizeNS','SizeWE','SizeNWSE','SizeNESW','No','UpArrow','NWPen')
for name in cursors:
    img=Image.new('RGBA',(64,64),(0,0,0,0))
    pen=ImageDraw.Draw(img)
    if name=='Crosshair':
        pen.ellipse((19,19,45,45),outline='#55C7FF',width=4)
        pen.line((32,3,32,61),fill='white',width=3)
        pen.line((3,32,61,32),fill='white',width=3)
        hotspot=(16,16)
    elif name in ('Wait','AppStarting'):
        pen.arc((8,8,56,56),10,295,fill='#55C7FF',width=9)
        hotspot=(16,16)
    elif name=='IBeam':
        pen.line((32,7,32,56),fill='white',width=5)
        pen.line((19,8,45,8),fill='#55C7FF',width=5)
        pen.line((19,55,45,55),fill='#55C7FF',width=5)
        hotspot=(16,16)
    else:
        pen.polygon([(7,4),(8,53),(21,41),(31,59),(42,53),(32,35),(52,35)],
            fill='#EDF9FF',outline='#3C90F4',width=3)
        hotspot=(2,2)
    stream=BytesIO()
    img.save(stream,format='ICO',sizes=[(32,32)])
    binary=bytearray(stream.getvalue())
    binary[2:4]=struct.pack('<H',2)
    binary[10:14]=struct.pack('<HH',*hotspot)
    (OUT/'cursors'/f'{name}.cur').write_bytes(binary)

tones={'Startup':(392,523,659),'Notification':(659,880),
    'Confirm':(523,784),'Alert':(330,262),'Shutdown':(523,392,294)}
for name,notes in tones.items():
    frames=bytearray()
    for hz in notes:
        for index in range(3307):
            t=index/22050
            volume=min(1.0,t*48)*max(0.0,min(1.0,(.15-t)*25))
            frames.extend(struct.pack('<h',int(8500*volume*math.sin(2*math.pi*hz*t))))
    with wave.open(str(OUT/'sounds'/f'BrenOS-{name}.wav'),'wb') as sound:
        sound.setnchannels(1)
        sound.setsampwidth(2)
        sound.setframerate(22050)
        sound.writeframes(frames)

# Concept boards use generated art only, not a fake replacement of protected Windows UI.
for label in ('Desktop','Start','Explorer','Settings','Login','Installer','Icons','System'):
    board=base.resize((1280,720),Image.Resampling.LANCZOS).convert('RGBA')
    d=ImageDraw.Draw(board,'RGBA')
    d.rounded_rectangle((90,80,1190,650),radius=26,fill=(15,31,53,220),
                        outline=(152,213,252,180),width=2)
    board.alpha_composite(Image.open(OUT/'brand'/'Nexus-128.png').convert('RGBA'),
                          (160,132))
    d=ImageDraw.Draw(board)
    # ASCII-safe label in previews; font provided by Pillow.
    d.text((320,165),'BrenOS  /  '+label,fill='#F2FBFF',stroke_width=1)
    d.rounded_rectangle((165,310,1100,362),radius=10,fill='#2F5175')
    d.rounded_rectangle((165,390,765,432),radius=9,fill='#32669A')
    d.rounded_rectangle((165,455,880,497),radius=9,fill='#2A486A')
    board.convert('RGB').save(OUT/'previews'/f'{label}.jpg',quality=90)
print('Created',len(icons),'icons,',len(cursors),'cursors,',
      len(tones),'sounds and',len(list((OUT/'wallpapers').glob('*.jpg'))),'wallpapers')
