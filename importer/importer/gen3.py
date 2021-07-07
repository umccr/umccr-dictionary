import hashlib


# https://github.com/uc-cdis/gdcdatamodel/blob/develop/gdcdatamodel/models/__init__.py#L163
def get_class_tablename_from_id(_id):
    return 'node_{}'.format(_id.replace('_', ''))


# https://github.com/uc-cdis/gdcdatamodel/blob/develop/gdcdatamodel/models/__init__.py#L370
def generate_edge_tablename(src_label, label, dst_label):
    """Generate a name for the edge table.
    Because of the limit on table name length on PostgreSQL, we have
    to truncate some of the longer names.  To do this we concatenate
    the first 2 characters of each word in each of the input arguments
    up to 10 characters (per argument).  However, this strategy would
    very likely lead to collisions in naming.  Therefore, we take the
    first 8 characters of a hash of the full, un-truncated name
    *before* we truncate and prepend this to the truncation.  This
    gets us a name like ``edge_721d393f_LaLeSeqDaFrLaLeSeBu``.  This
    is rather an undesirable workaround. - jsm
    """

    tablename = 'edge_{}{}{}'.format(
        src_label.replace('_', ''),
        label.replace('_', ''),
        dst_label.replace('_', ''),
    )

    # If the name is too long, prepend it with the first 8 hex of it's hash
    # truncate the each part of the name
    if len(tablename) > 40:
        tablename = 'edge_{}_{}'.format(
            str(hashlib.md5(tablename.encode('utf-8')).hexdigest())[:8],
            "{}{}{}".format(
                ''.join([a[:2] for a in src_label.split('_')])[:10],
                ''.join([a[:2] for a in label.split('_')])[:7],
                ''.join([a[:2] for a in dst_label.split('_')])[:10],
            )
        )
        # print('Shortening {} -> {}'.format(oldname, tablename))

    return tablename
