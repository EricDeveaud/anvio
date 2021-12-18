#!/usr/bin/env python
# -*- coding: utf-8

import sys
import argparse
import re

import anvio.db as db
import anvio.utils as utils
import anvio.terminal as terminal

from anvio.errors import ConfigError

current_version, next_version = [x[1:] for x in __name__.split('_to_')]

run = terminal.Run()
progress = terminal.Progress()


def migrate(db_path):
    if db_path is None:
        raise ConfigError("No database path is given.")

    utils.is_kegg_modules_db(db_path)

    # make sure the current version is 2
    modules_db = db.DB(db_path, None, ignore_version = True)
    if str(modules_db.get_version()) != current_version:
        modules_db.disconnect()
        raise ConfigError("Version of this modules database is not %s (hence, "
                          "this script cannot really do anything)." % current_version)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='A simple script to upgrade KEGG Modules database from version 2 to version 3')
    parser.add_argument('modules_db', metavar = 'MODULES_DB', help = 'KEGG Modules database')
    args, unknown = parser.parse_known_args()

    try:
        migrate(args.modules_db)
    except ConfigError as e:
        print(e)
        sys.exit(-1)
