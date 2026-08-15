"""
Generate a proper multi-size Windows ICO file by writing the ICO format manually.
Pillow's append_images for ICO doesn't always behave consistently, so we write binary.
"""
import struct
from PIL import Image
import io
import os

src = r'd:\Flutter\Qubah App\qubah_learning_app\assets\images\logo.png'
dst = r'd:\Flutter\Qubah App\qubah_learning_app\windows\runner\resources\app_icon.ico'

img = Image.open(src).convert('RGBA')

# Square with transparent background
size = max(img.size)
square = Image.new('RGBA', (size, size), (0, 0, 0, 0))
offset = ((size - img.width) // 2, (size - img.height) // 2)
square.paste(img, offset)

icon_sizes = [16, 24, 32, 48, 64, 128, 256]
png_blobs = []
for s in icon_sizes:
    resized = square.resize((s, s), Image.LANCZOS)
    buf = io.BytesIO()
    resized.save(buf, format='PNG')
    png_blobs.append(buf.getvalue())

# ICO format:
# Header: 6 bytes (reserved=0, type=1, count=N)
# Directory: N * 16 bytes each
# Image data follows

n = len(icon_sizes)
header = struct.pack('<HHH', 0, 1, n)  # reserved, type=1 (icon), count

# Calculate offsets: header(6) + directory(n*16) + data
dir_offset = 6 + n * 16
offsets = []
cur_offset = dir_offset
for blob in png_blobs:
    offsets.append(cur_offset)
    cur_offset += len(blob)

directory = b''
for i, (s, blob) in enumerate(zip(icon_sizes, png_blobs)):
    w = s if s < 256 else 0  # 0 means 256 in ICO
    h = s if s < 256 else 0
    directory += struct.pack('<BBBBHHII',
        w,          # width
        h,          # height
        0,          # color count (0 = no palette)
        0,          # reserved
        1,          # planes
        32,         # bit count
        len(blob),  # size of image data
        offsets[i], # offset of image data
    )

with open(dst, 'wb') as f:
    f.write(header)
    f.write(directory)
    for blob in png_blobs:
        f.write(blob)

print(f'Saved ICO: {dst}')
print(f'File size: {os.path.getsize(dst):,} bytes')
print(f'Embedded sizes: {icon_sizes}')
