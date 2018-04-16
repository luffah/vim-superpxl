"""
    Pxl to png

"""
# Copyright (C) 2018  luffah <luffah@runbox.com>
# Author: luffah <luffah@runbox.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
from os.path import isfile
from PIL import Image
import colorsys

COLORTOCHR = {
    # format RGB
    '000': '0',
    '001': '4',
    '010': '0',
    '100': '1',
    '011': '0',
    '101': '5',
    '110': '3',
    '111': '8',
    '002': '4',
    '020': '2',
    '200': '1',
    '201': '3',
    '202': '5',
    '012': '4',
    '022': '6',
    '102': '5',
    '112': '4',
    '120': '2',
    '121': '2',
    '122': '6',
    '210': '1',
    '021': '6',
    '211': '1',
    '212': '5',
    '220': '3',
    '221': '3',
    '222': '7',
    '003': 'C',
    '013': 'C',
    '023': 'E',
    '030': 'A',
    '031': 'A',
    '032': 'A',
    '033': 'E',
    '103': '9',
    '113': 'C',
    '123': 'C',
    '130': 'A',
    '131': 'A',
    '132': 'D',
    '133': 'D',
    '203': 'C',
    '213': 'E',
    '223': 'E',
    '230': 'B',
    '231': 'B',
    '232': 'A',
    '233': 'F',
    '300': '9',
    '301': '9',
    '302': 'D',
    '303': 'D',
    '310': '9',
    '311': '9',
    '312': '9',
    '313': 'D',
    '320': 'B',
    '321': 'B',
    '322': 'D',
    '323': 'F',
    '330': 'B',
    '331': 'B',
    '332': 'B',
    '333': 'F'
}

def nearest_color_hsl2(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '

    ph,ps,pv = colorsys.rgb_to_hsv(pr/255.,pg/255.,pb/255.)
    distances = []

    for k, (r, g, b) in colormap.items():
        h,s,v = colorsys.rgb_to_hsv(r/255.,g/255.,b/255.)
        dh = min(abs(ph-h), 360-abs(ph-h)) / 180.0
        ds = abs(ps-s)
        dv = abs(pv-v) / 255.0

        distances.append([dh*dh+ds*ds+dv*dv, k])
    distances.sort()
    return distances[0][1]

def nearest_color_hsl_rgb(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '

    ph,ps,pv = colorsys.rgb_to_hsv(pr/255.,pg/255.,pb/255.)
    distances = []

    for k, (r, g, b) in colormap.items():
        h,s,v = colorsys.rgb_to_hsv(r/255.,g/255.,b/255.)
        distances.append(
            [(pow(h - ph, 2) + pow(s - ps, 2) + pow(v - pv, 2))*(2*pow(r - pr, 2) + 4*pow(g - pg, 2) + 3*pow(b - pb, 2)),
             k])

    distances.sort()
    return distances[0][1]

def nearest_color_hsl(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '

    ph,ps,pv = colorsys.rgb_to_hsv(pr/255.,pg/255.,pb/255.)
    distances = []

    for k, (r, g, b) in colormap.items():
        h,s,v = colorsys.rgb_to_hsv(r/255.,g/255.,b/255.)
        distances.append(
            [(pow(h - ph, 2) + pow(s - ps, 2) + pow(v - pv, 2)),
             k])

    distances.sort()
    return distances[0][1]

def nearest_color_human(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '
    distances = []

    for k, (r, g, b) in colormap.items():
        distances.append(
            [(2 if k in ['7','8'] else 1)*(2*pow(r - pr, 2) + 4*pow(g - pg, 2) + 3*pow(b - pb, 2)),
             k])

    distances.sort()
    return distances[0][1]

def nearest_color_rgb332(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '
    distances = []

    for k, (r, g, b) in colormap.items():
        distances.append(
            [(3 if k in ['7','8'] else 1)*(2*pow(r - pr, 2) + 3*pow(g - pg, 2) + 2*pow(b - pb, 2)),
             k])

    distances.sort()
    return distances[0][1]

def nearest_color_rgb233(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '
    distances = []

    for k, (r, g, b) in colormap.items():
        distances.append(
            [(2 if k in ['7','8'] else 1)*(2*pow(r - pr, 2) + 3*pow(g - pg, 2) + 3*pow(b - pb, 2)),
             k])

    distances.sort()
    return distances[0][1]

def nearest_color_rgb(pix, colormap):
    """nearest_color

    :param pix:
    :param colormap:
    """
    (pr, pg, pb, ptr) = pix

    if ptr < 100:
        return ' '
    distances = []

    for k, (r, g, b) in colormap.items():
        distances.append(
            [(pow(r - pr, 2) + pow(g - pg, 2) + pow(b - pb, 2)),
             k])

    distances.sort()
    return distances[0][1]


def trpix2chr(pix, colortochr):
    """trpix2chr

    :param pix:
    :param colortochr:
    """
    # rbga
    if pix[3] < 100:
        return ' '
    else:
        cod = ""
        for a in pix[0:3]:
            cod += '3' if a > 192 else '2' if a > 128 else '1' if a > 64 else '0'
        return colortochr[cod]


def export_as_png(buf, fname, colormap, factor=2):
    """export_as_png

    :param buf:
    :param fname:
    :param colormap: a table {pixel char -> rgb values}
    :param factor: to how many line correspond 1 line (a character is a rectangle 1x2, so you shall set 2 to respect ratio)
    """
    img = Image.new('RGBA', (max([len(a) for a in buf]), len(buf) * factor))
    pixels = img.load()

    for i in range(len(buf)):
        for j in range(len(buf[i])):
            char = buf[i][j]
            if char in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']:
                for f in range(factor):
                    pixels[j, i * factor + f] = colormap[char]

    img.save(fname, 'PNG')


def import_png(fpath,  maxwidth, colorfunc=trpix2chr, colordata=COLORTOCHR,
               factor=1, factormode=0, scale_filter=Image.BILINEAR):
    """import_png

    :param fpath:
    :param maxwidth:
    :param colorfunc: function which translate pixel to char
    :param colordata: parameter for colorfunc
    :param factor: to how many line correspond 1 line (a character is a rectangle 1x2, so you shall set 2 to respect ratio)
    :param factormode: 0 let PIL reduce the image, 1 make it by removing 1 line / 2
    :param scale_filter: PIL interpolation
       Image.NEAREST      -> use nearest neighbour
       Image.BILINEAR     -> linear interpolation in a 2x2 environment
       Image.BICUBIC      -> cubic spline interpolation in a 4x4 environment
       Image.ANTIALIAS
    """
    ret = []
    if isfile(fpath):
        im = Image.open(fpath)
        print("%s openned" % fpath)
    else:
        print("%s doesn't exists" % fpath)
    width, height = im.size

    if width > maxwidth:
        height = ((maxwidth / width) * height)
        width = maxwidth
    height = int(height + 0.5)
    size = (width, height)

    if factormode == 0 and factor > 1:
        height = height / factor
        height = int(height + 0.5)
        size = (width, height)

    im = im.resize(size, scale_filter)
    im = im.convert('RGBA')

    width, height = im.size
    pixels = im.load()
    for j in range(height):
        ret.append("")
        for i in range(width):
            ret[j] += colorfunc(pixels[i, j], colordata)

    if factormode == 1 and factor > 1:
        newret = []
        for i in range(0, len(ret) - 1, factor):
            newret.append(ret[i])
        ret = newret
    return ret
