import sys, yaml, os
from tabulate import tabulate


if __name__ == "__main__":
    repo_path = sys.argv[1]
    entry_filter = sys.argv[2]
    index_path = repo_path + "/index.yaml"
    if os.path.isfile(index_path):
        with open(index_path, 'r') as inputfile:
            output = []
            index = yaml.safe_load(inputfile.read())
            for name, entry_list in index['entries'].items():
                if entry_filter != '*' and entry_filter not in name:
                    continue

                for entry in entry_list:
                    urls = []
                    for url in entry['urls']:
                        urls.append(repo_path + "/" + url)

                    output.append([
                        entry['name'], entry['version'], entry['created'], ";".join(urls)
                    ])

            print(tabulate(output, headers=['Name', 'Version', 'Created', 'Path']))
