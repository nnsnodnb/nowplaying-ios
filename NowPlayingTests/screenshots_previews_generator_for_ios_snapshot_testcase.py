#!/usr/bin/env python3

import glob

from pathlib import Path


def convert_device_name(size: str, scale: str) -> str:
    if size.startswith('320x') and scale == '2x':
        return 'iPhone SE'
    elif size.startswith('375x') and scale == '2x':
        return 'iPhone 8'
    elif size.startswith('414x') and scale == '3x':
        return 'iPhone 8 Plus'
    elif size.startswith('414x') and scale == '2x':
        return 'iPhone 11'
    elif size.startswith('375x') and scale == '3x':
        return 'iPhone 11 Pro'
    elif size.startswith('414x') and scale == '3x':
        return 'iPhone 11 Pro Max'
    else:
        return 'Unknown device'


def create_markdown():
    markdown = ''

    reference_image_dir = Path(__file__).parent / 'ReferenceImages_64'
    folders = sorted(glob.glob(f'{str(reference_image_dir)}/*'))
    for folder in folders:
        screen_name = folder.split('/')[::-1][0]
        markdown += f'# {screen_name}\n\n'

        images_path = sorted(glob.glob(f'{str(reference_image_dir / screen_name)}/*.png'))
        for components in zip(*[iter(images_path)] * 6):
            method_name, identifier = components[0].split('/')[::-1][0].split('_')[:2]
            markdown += f'## {method_name.replace("test", "")}\n\n'
            markdown += f'| {" | ".join([identifier for _ in range(6)])} |\n'
            markdown += f'{" :-------: ".join(["|" for _ in range(7)])}\n'

            data = {
                'os': [],
                'device_name': [],
                'image': []
            }
            for path in components:
                filename = path.split('/')[::-1][0]
                identifier, os_1, os_2, size_scale = filename.split('_')[1:]
                os = f'{os_1}.{os_2}'
                size, scale = size_scale.split('@')
                scale = scale.replace('.png', '')
                device_name = convert_device_name(size, scale)

                data['os'].append(os)
                data['device_name'].append(device_name)
                data['image'].append(f'<img src="./ReferenceImages_64/{screen_name}/{filename}" width="150px">')

            for key, items in data.items():
                markdown += f'| {" | ".join(items)} |\n'
        else:
            markdown += "\n"

    #print(markdown)
    with open(Path(__file__).parent / 'ReferenceImage.md', 'w') as output:
        output.write(markdown)


if __name__ == '__main__':
    create_markdown()
