#!/bin/env python3
def parse_input(lines):
    """Parse a line with xmin ymin xmax ymax."""
    lines = [x.split(' ') for x in lines]
    for line in lines:
        line[:] = [int(x) for x in line]
    return lines


def parse_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('input', help='Input file with list of xmin ymin xmax ymax')
    parser.add_argument('output', help='Output KITTI formatted file (see https://github.com/' +
                        'NVIDIA/DIGITS/blob/master/digits/extensions/data/objectDetection/README.md and' +
                        'http://www.cvlibs.net/datasets/kitti/eval_object.php)')
    return parser.parse_args()


def main():
    args = parse_args()
    with open(args.input) as input_file, open(args.output, 'w') as output:
        coords = parse_input(input_file.readlines())
        for left, top, right, bottom in coords:
            output.write('{type} 0 0 0 {left} {top} {right} {bottom} 0 0 0 0 0 0 0 0\n'
                         .format(type='Cone', left=left, top=top, right=right, bottom=bottom))

if __name__ == "__main__":
    main()
