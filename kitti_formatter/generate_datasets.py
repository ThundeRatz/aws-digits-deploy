#!/usr/bin/env python3
import formatter
import os
import random
import shutil


def parse_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('input', help='Directory with images and labels folders')
    parser.add_argument('output', help='Output directory')
    return parser.parse_args()


def get_file_list(directory):
    images = {x[:-4] for x in os.listdir(os.path.join(directory, 'images')) if x.endswith('.png')}
    labels = {x[:-4] for x in os.listdir(os.path.join(directory, 'labels')) if x.endswith('.txt')}
    empty_labels = set()
    for label in labels:
        with open(os.path.join(directory, 'labels', '{}.txt'.format(label))) as f:
            if len(f.read()) < 3:
                print('Ignoring label file {} with no detections'.format(label))
                empty_labels.add(label)
    labels -= empty_labels
    if images - labels:
        print('Missing labels: {}'.format(images - labels))
    if labels - images:
        print('Missing images: {}'.format(labels - images))
    return images & labels


def create_dir_structure(output):
    os.makedirs(output, exist_ok=True)
    for d in 'train', 'val':
        os.mkdir(os.path.join(output, d))
        os.mkdir(os.path.join(output, d, 'labels'))
        os.mkdir(os.path.join(output, d, 'images'))


def main(args):
    files = get_file_list(args.input)
    create_dir_structure(args.output)

    validation = set(random.sample(files, len(files) // 10))
    train = files - validation

    for i, f in enumerate(validation):
        shutil.move(os.path.join(args.input, 'images', '{}.png'.format(f)),
                    os.path.join(args.output, 'val', 'images', '{:06}.png'.format(i + 1)))
        formatter.kitti_format(os.path.join(args.input, 'labels', '{}.txt'.format(f)),
                               os.path.join(args.output, 'val', 'labels', '{:06}.txt'.format(i + 1)))

    for j, f in enumerate(train):
        shutil.move(os.path.join(args.input, 'images', '{}.png'.format(f)),
                    os.path.join(args.output, 'train', 'images', '{:06}.png'.format(i + j + 1)))
        formatter.kitti_format(os.path.join(args.input, 'labels', '{}.txt'.format(f)),
                               os.path.join(args.output, 'train', 'labels', '{:06}.txt'.format(i + 1)))

if __name__ == '__main__':
    main(parse_args())
