import sys, yaml, os


if __name__ == "__main__":
    manifest_path = sys.argv[1]
    output_path = sys.argv[2]
    with open(manifest_path, 'r') as inputfile:
        manifest = yaml.safe_load(inputfile.read())['manifest']
        with open(output_path, 'w+') as outputfile:
            outputfile.write(manifest)
