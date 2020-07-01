import sys, yaml, os
import re


if __name__ == "__main__":
    chart_path = os.path.abspath(sys.argv[1])
    context_name = sys.argv[2]
    comp_template_name = sys.argv[3]

    # Check if name follow the convention
    pattern = re.compile("^[A-Za-z_]+[A-Za-z_0-9\.\-]*$")
    if not pattern.match(context_name):
        print("\033[1;31mERROR: Invalid naming convention!\033[0m")
        exit(1)

    # Check if name already used in values.yaml
    if os.path.isfile(chart_path + '/values.yaml'):
        with open(chart_path + '/values.yaml', 'r') as valuefile:
            values = yaml.safe_load(valuefile.read())
            if values and context_name in values:
                print("\033[1;31mERROR: {} already exist in values.yaml\033[0m".format(context_name))
                exit(1)

    if os.path.isfile(chart_path + '/templates/' + comp_template_name):
        print("\033[1;31mERROR: {} already exist in templates directory\033[0m".format(comp_template_name))
        exit(1)
