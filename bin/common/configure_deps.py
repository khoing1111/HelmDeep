import sys, yaml, os, tarfile

def add_dep(chart_manifest, dep_manifest, dep_repo):
    chart_manifest['dependencies'].append({
        'name': dep_manifest['name'],
        'version': dep_manifest['version'],
        'repository': 'file:///home/app/repo' + dep_repo
    })


def get_dep_info_from_file(dep_manifest_file):
    with open(dep_manifest_file, 'r') as depfile:
        dep_manifest = yaml.safe_load(depfile)
        return dep_manifest['name'], dep_manifest['version']


if __name__ == "__main__":
    """
    This script is used to update chart manifest file (Chart.yaml) with our dependencies.
    """
    chart_dir = os.path.abspath(sys.argv[1])
    is_release = True if sys.argv[2] == 'yes' else False
    dependencies = sys.argv[3:]
    if is_release and len(dependencies) == 0:
        print("\033[1;31mERROR: Release need at least one dependency!\033[0m")
        exit(1)

    repo_home = os.environ['REPO_HOME']
    if dependencies:
        chart_manifest = {}

        # Load manifest file
        with open(chart_dir + "/Chart.yaml", "r") as chartfile:
            chart_manifest = yaml.safe_load(chartfile)
            chart_manifest['dependencies'] = []
            chart_manifest['helmdeep'] = { 'dependencies': [] }
            for dependency in dependencies:
                dependency = os.path.abspath(dependency)

                # If dependency is a path to a chart directory
                if os.path.isdir(dependency):
                    with open(dependency + '/Chart.yaml', 'r') as depfile:
                        dep_manifest = yaml.safe_load(depfile)
                        chart_manifest['dependencies'].append({
                            'name': dep_manifest['name'],
                            'version': dep_manifest['version'],
                            'repository': 'file://' + dependency
                        })

                # If dependency is a path to zip file (A package)
                elif os.path.isfile(dependency):
                    with tarfile.open(dependency, "r:gz") as tar:
                        for tarinfo in tar:
                            file_name = tarinfo.name.split('/')[1]
                            if file_name == 'Chart.yaml':
                                dep_manifest = yaml.safe_load(tar.extractfile(tarinfo))
                                # If package inside our repository home
                                repo_dir = os.path.dirname(dependency)
                                if repo_dir[:len(repo_home)] == repo_home:
                                    repository = 'repo://' + repo_dir[len(repo_home):]
                                else:
                                    repository = 'pack://' + dependency

                                chart_manifest['helmdeep']['dependencies'].append({
                                    'name': dep_manifest['name'],
                                    'version': dep_manifest['version'],
                                    'repository': repository
                                })

                                break


        with open(chart_dir + "/Chart.yaml", "w+") as chartfile:
            chartfile.write(yaml.safe_dump(chart_manifest))
