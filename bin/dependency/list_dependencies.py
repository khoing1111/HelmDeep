import sys, yaml, os
from tabulate import tabulate


if __name__ == "__main__":
    chart_path = os.path.abspath(sys.argv[1])
    with open(chart_path + "/Chart.yaml", 'r') as inputfile:
        chart_des = yaml.safe_load(inputfile.read())
        dependencies = chart_des.get('helmdeep', {}).get('dependencies', [])
        output = []
        for dep in dependencies:
            output.append([
                dep['name'], dep['version'], dep['repository']
            ])

        print(tabulate(output, headers=['Name', 'Version', 'Repository']))
