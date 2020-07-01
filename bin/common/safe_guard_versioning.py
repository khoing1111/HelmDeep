import sys, yaml, os


if __name__ == "__main__":
    """
    This script is used to check if the chart package already exist inside repository.
    """
    chart_dir = sys.argv[1]
    repo_dir = sys.argv[2]

    # Load chart version
    chart_des = chart_dir + "/Chart.yaml"
    with open(chart_des, 'r') as inputfile:
        chart_des = yaml.safe_load(inputfile.read())

    name = chart_des['name']
    version = chart_des['version']

    # Load current repo indexes and find if package version exist
    index_path = repo_dir + '/index.yaml'
    if os.path.isfile(index_path):
        with open(index_path, 'r') as inputfile:
            index = yaml.safe_load(inputfile.read())
            for entry in index['entries'].get(name, []):
                if entry['version'] == version:
                    print("\033[1;31mERROR: package {} already have version {}\033[0m".format(name, version))
                    exit(1)
