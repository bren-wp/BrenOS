#!/usr/bin/env python3
"""Static regression test for all independently built BrenOS visual assets."""
from pathlib import Path
import json, struct, wave
from PIL import Image

root=Path(__file__).resolve().parents[1]
out=root/'assets'/'generated'
source=json.loads((root/'assets'/'source'/'icons.json').read_text(encoding='utf8'))
assert len(source)==50 and len({p['name'] for p in source})==50
for item in source:
    name=item['name']
    assert (out/'icons'/'svg'/f'{name}.svg').is_file()
    with Image.open(out/'icons'/'png'/f'{name}.png') as image:
        assert image.size==(512,512)
    with Image.open(out/'icons'/'ico'/f'{name}.ico') as image:
        assert image.format=='ICO'
for theme in ('Flow','Dawn','Midnight'):
    for label,dims in (('FHD',(1920,1080)),('QHD',(2560,1440)),
                       ('4K',(3840,2160)),('Ultrawide',(3440,1440))):
        with Image.open(out/'wallpapers'/f'BrenOS-{theme}-{label}.jpg') as image:
            assert image.size==dims, (theme,label,image.size)
    with Image.open(out/'wallpapers'/f'BrenOS-{theme}.jpg') as image:
        assert image.size==(3840,2160)
with Image.open(out/'brand'/'BrenOS.ico') as image:
    assert image.format=='ICO'
cursors=list((out/'cursors').glob('*.cur'))
assert len(cursors)==15
for cursor in cursors:
    data=cursor.read_bytes()
    assert data[:4]==b'\x00\x00\x02\x00',cursor
    assert struct.unpack('<H',data[4:6])[0]>=1
sounds=list((out/'sounds').glob('*.wav'))
assert len(sounds)==5
for sound in sounds:
    with wave.open(str(sound),'rb') as wav:
        assert wav.getnchannels()==1
        assert wav.getframerate()==22050
        assert wav.getnframes()>1000
previews=list((out/'previews').glob('*.jpg'))
assert len(previews)==8
print('PASS: 50 icons; 15 cursors; 5 sounds; wallpapers for FHD, QHD, 4K and ultrawide')
