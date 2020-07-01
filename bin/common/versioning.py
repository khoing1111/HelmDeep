import sys, yaml


if __name__ == "__main__":
    version_type = sys.argv[1]
    chart_dir = sys.argv[2]
    with open(chart_dir + '/Chart.yaml', 'r') as manifestfile:
        manifest = yaml.safe_load(manifestfile)
        oldversion = manifest['version']
        major, minor, patch = oldversion.split('.')
        if version_type == 'major':
            major = str(int(major) + 1)
        elif version_type == 'minor':
            minor = str(int(minor) + 1)
        elif version_type == 'patch':
            patch = str(int(patch) + 1)
        else:
            raise Exception("Invalid type " + version_type)

        newversion = '.'.join([major, minor, patch])
        print("Update from: {} => To: {}".format(oldversion, newversion))
        manifest['version'] = newversion

    with open(chart_dir + '/Chart.yaml', 'w+') as manifestfile:
        manifestfile.write(yaml.safe_dump(manifest))
