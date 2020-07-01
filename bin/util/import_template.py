import sys, yaml, os
import re
import ruamel.yaml as ruamel_yaml
from ruamel.yaml.compat import StringIO


class MyYAML(ruamel_yaml.YAML):
    def dump(self, data, stream=None, **kw):
        inefficient = False
        if stream is None:
            inefficient = True
            stream = StringIO()
        ruamel_yaml.YAML.dump(self, data, stream, **kw)
        if inefficient:
            return stream.getvalue()


def _recursive_update_values(values, prefix='', comment=None):
    result = values
    if isinstance(values, list):
        result = []
        for index, item in enumerate(values):
            result.append(
                _recursive_update_values(item, prefix + '[' + str(index) + ']')
            )
    elif isinstance(values, dict):
        for key, value in values.items():
            result[key] = _recursive_update_values(value, prefix + '.' + key)
    elif values == '__TODO__':
        user_input = input(">>> " + prefix + ": ")
        if user_input != '#skip':
            result = yaml.safe_load(user_input)

    return result


def update_values_using_user_input(values):
    yaml = MyYAML()
    yaml.indent(mapping=4, sequence=4, offset=4)
    values = yaml.load(values)
    values = _recursive_update_values(values)
    return yaml.dump(values)


if __name__ == "__main__":
    template_usage_path = os.path.abspath(sys.argv[1])
    chart_path = os.path.abspath(sys.argv[2])
    context_uid = sys.argv[3]
    comp_template_name = sys.argv[4]
    should_fill_data = sys.argv[5]

    print("Configurating the template file " + comp_template_name)
    with open(template_usage_path + '/template.yaml', 'r') as templatefile:
        template = templatefile.read().replace('__CTX_UID__', context_uid)
        with open('{}/templates/{}'.format(chart_path, comp_template_name), 'w+') as dest_templatefile:
            dest_templatefile.write(template)

    print("Configurating the values.yaml file")
    with open(template_usage_path + '/values.yaml', 'r') as valuesfile:
        values = valuesfile.read().replace('__CTX_UID__', context_uid)
        if should_fill_data == "yes":
            print(">> Filling template values. (Use #skip to skip over data).")
            values = update_values_using_user_input(values)

        with open(chart_path + '/values.yaml', 'a') as dest_valuesfile:
            dest_valuesfile.write('\n\n')
            dest_valuesfile.write(values)
