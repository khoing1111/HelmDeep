from shutil import copyfile
import sys, yaml
import os


def load_entry(repo_dir, entry, chart_dir):
    for url in entry['urls']:
        src = repo_dir + '/' + url
        dest = chart_dir + '/charts/' + url
        dest_dir = os.path.dirname(dest)
        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)

        print("Copy repo package from {} to {}".format(src, dest))
        copyfile(src, dest)


def load_dep_from_repo(dep, chart_dir):
    """
    This method use the index.yaml in repo directory to find and load the tar.gz file
    """
    repo_dir = os.environ['REPO_HOME'] + dep['repository'].split('repo://')[1]
    index_dir = repo_dir + '/index.yaml'
    with open(index_dir, 'r') as inputfile:
        index = yaml.safe_load(inputfile.read())
        name = dep['name']
        version = dep['version']
        if name in index.get('entries', {}):
            for entry in index['entries'][name]:
                if entry['version'] == version:
                    load_entry(repo_dir, entry, chart_dir)
                    return

    print("\033[1;31mERROR: Dependencies {} version {} not found in repo {}\033[0m".format(name, version, repo_dir))
    exit(1)


def load_dep_from_package(dep, chart_dir):
    src = dep['repository'].split('pack://')[1]
    packge_filename = os.path.basename(src)
    dest = chart_dir + '/charts/' + packge_filename
    dest_dir = os.path.dirname(dest)
    print("Copy package from {} to {}".format(src, dest))
    copyfile(src, dest)


if __name__ == "__main__":
    """
    Because Helm do not support local dependencies of tar.gz file. We load it by hand.
    Any dependencies with repo:// will need to load using this method.

    This script load dependencies list from Chart.yaml manifest file and search it inside repo directory using index.yaml file.
    Then copy the tar.gz file into sub charts folder.
    """
    chart_dir = os.path.abspath(sys.argv[1])
    with open(chart_dir + "/Chart.yaml", 'r') as inputfile:
        chart_des = yaml.safe_load(inputfile.read())
        dependencies = chart_des.get('helmdeep', {}).get('dependencies', [])
        for dep in dependencies:
            repository = dep['repository']
            repo_type = repository[:7]
            if  repo_type == 'repo://':
                load_dep_from_repo(dep, chart_dir)
            elif repo_type == 'pack://':
                load_dep_from_package(dep, chart_dir)
