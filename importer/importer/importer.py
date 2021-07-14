"""Utility, creates projects and nodes.  Deletes existing nodes of input type by default."""
import uuid
import os
import json
from datetime import datetime
import click

from importer.ioutils import reader
from importer.gen3 import generate_edge_tablename, get_class_tablename_from_id


PROJECT_ID = None


def write_edge(link, line, project_id):
    """Writes edge file ready for sql import. Strips edge from submission node."""
    edges = line.get(link['src_edge_property'], None)
    if not edges:
        return line

    if not isinstance(edges, (list,)):
        edges = [edges]
    src_id = get_node_id(line)

    for edge in edges:
        if link['src_edge_property'] == 'projects':
            dst_id = get_project_node_id(project_id)
        else:
            dst_id = get_uuid(edge.get('submitter_id', edge.get('code')))
        link['handle'].write('{}\t{}\t{}\t{}\t{}\n'.format(
            src_id, dst_id, '{}', '{}', '{}'))
    del line[link['src_edge_property']]
    return line


def get_uuid(s):
    return uuid.uuid5(uuid.NAMESPACE_DNS, s.lower())


def get_node_id(line):
    """Returns uniq submitter_id."""
    if line['type'] == 'project':
        node_id = get_uuid(line['code'])
    else:
        node_id = get_uuid(line['submitter_id'])
    return node_id


def write_node(handle, line):
    """Writes edge file ready for sql import. Strips edge from submission node."""
    global PROJECT_ID
    node_id = get_node_id(line)
    if line['type'] == 'project':
        PROJECT_ID = node_id

    now = datetime.utcnow().isoformat()
    # ensure timestamps
    for p in ['updated_datetime', 'created_datetime']:
        if p not in line:
            line[p] = now
    handle.write('{}\t{}\t{}\t{}\n'.format(
        node_id, '{}', '{}', json.dumps(line, separators=(',', ':'))))
    return line


def get_tables(schema, line):
    """Consolidates node and edge table names"""
    assert 'type' in line, 'no "type" in record {}'.format(line)
    type = line['type']
    assert f"{type}.yaml" in schema.keys()
    # print(schema[f"{type}.yaml"])
    type_schema = schema[f"{type}.yaml"]
    assert 'id' in type_schema, f'{type} not found in schema {type_schema}'
    assert type == type_schema['id'], f'schema id should be the same as type {type}'
    table_name = get_class_tablename_from_id(type)
    tables = {'node_table': table_name, 'links': []}
    for link in type_schema['links']:
        if 'subgroup' not in link:
            src_edge_property = link['name']
            edge_table = generate_edge_tablename(type, link['label'], link['target_type'])
            tables['links'].append(
                {'src_edge_property': src_edge_property, 'edge_table': edge_table})
        else:
            for subgroup in link['subgroup']:
                src_edge_property = subgroup['name']
                edge_table = generate_edge_tablename(type, subgroup['label'], subgroup['target_type'])
                tables['links'].append(
                    {'src_edge_property': src_edge_property, 'edge_table': edge_table})
    return tables


def get_project_node_id(project_id):
    """Returns the node_id"""
    return PROJECT_ID


DEFAULT_INPUT_DIR = 'data'
DEFAULT_OUTPUT_DIR = 'output'
DEFAULT_PROGRAM = None
DEFAULT_PROJECT = None
DEFAULT_PATH = '**/*.json*'
DEFAULT_BATCH_SIZE = 100
DEFAULT_DELETE_FIRST = False

DEFAULT_CREDENTIALS_PATH = os.path.join('config', 'credentials.json')


@click.command()
@click.option('--path', default=DEFAULT_INPUT_DIR, help='Read json from here')
@click.option('--program', default=DEFAULT_PROGRAM, help='owning program')
@click.option('--project', default=DEFAULT_PROJECT, help='owning project')
@click.option('--delete_first', default=DEFAULT_DELETE_FIRST, help='delete all data first')
@click.option('--output_dir', default=DEFAULT_OUTPUT_DIR, help='write files to this dir')
def import_graph(path, program, project, delete_first, output_dir):
    """Transforms submission record to node and edge files"""
    assert path
    assert program, "please specify program"
    assert project, "please specify project"
    schema = json.load(open(f"schema/{project}.json"))
    imports = open(f"{path}/{project}/DataImportOrder.txt", "r").read().splitlines()

    for name in imports:
        p = f"{path}/{project}/{name}.json"
        tables = None
        print(f"echo INFO reading {p}")
        for line in reader(p):
            if 'project_id' not in line:
                line['project_id'] = f'{program}-{project}'
            assert 'project_id' in line, f'must have project_id {line}'
            assert 'type' in line, f'must have type {line}'
            if line['type'] != 'project':
                assert 'submitter_id' in line, f'must have submitter_id {line}'
            if not tables:
                tables = get_tables(schema, line)
                tables['handle'] = open(
                    '{}/{}/{}.tsv'.format(output_dir, project, tables['node_table']), 'w')
                for link in tables['links']:
                    link['handle'] = open(
                        '{}/{}/{}.tsv'.format(output_dir, project, link['edge_table']), 'w')
                if delete_first:
                    print(f"echo INFO deleting {program}-{project}")
                    print(f"$PSQL -c \"delete from {tables['node_table']} where _props->>'project_id' = '{program}-{project}'  ;\"")

            for link in tables['links']:
                line = write_edge(link, line, f'{program}-{project}')
            write_node(tables['handle'], line)

        tables['handle'].close()
        node_path = '{}/{}/{}.tsv'.format(output_dir,
                                          project, tables['node_table'])
        print(f"echo INFO importing {tables['node_table']}")
        print(f"cat  {node_path} | $PSQL -c \"copy {tables['node_table']}(node_id, acl, _sysan,  _props) from stdin  csv delimiter E'\\t' quote E'\\x02' ;\"")
        for link in tables['links']:
            link['handle'].close()
            edge_path = '{}/{}/{}.tsv'.format(output_dir,
                                              project, link['edge_table'])
            print(f"echo INFO importing {link['edge_table']}")
            print(f"cat  {edge_path} | $PSQL -c \"copy {link['edge_table']}(src_id, dst_id, acl, _sysan, _props) from stdin  csv delimiter E'\\t' quote E'\\x02' ;\"")


if __name__ == "__main__":
    import_graph()
