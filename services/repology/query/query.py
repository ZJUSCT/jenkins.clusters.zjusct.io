#!/usr/bin/env python3
#
# Copyright (C) 2023 Repology contributors
#
# This file is part of repology
#
# repology is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# repology is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with repology.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import sys
from collections import defaultdict
import os

from pytablewriter import MarkdownTableWriter

from repology.config import config
from repology.database import Database
from repology.querymgr import QueryManager


def read_lines_from_file(filepath: str) -> list[str]:
    """Read lines from a text file and return as a list, removing empty lines and comments."""
    result = []
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                # Split line by whitespace and add each item
                for item in line.split():
                    if item:  # Ensure we're not adding empty strings
                        result.append(item)
    # remove duplicates
    result = list(set(result))
    return result


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Query repology database and show package existence across repositories',
                                    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument('-D', '--dsn', default=config['DSN'], help='database connection params')
    parser.add_argument('-Q', '--sql-dir', default=config['SQL_DIR'], help='path to directory with sql queries')
    
    parser.add_argument('-v', '--pkgnames-file', required=True, help='file containing list of visible package names to search for')
    parser.add_argument('-r', '--repos-file', required=True, help='file containing list of repositories to check')
    
    return parser.parse_args()


def main() -> int:
    options = parse_arguments()
    
    # Read pkgnames and repos from files
    try:
        pkgnames = read_lines_from_file(options.pkgnames_file)
        if not pkgnames:
            print(f"Error: No visible names found in file: {options.pkgnames_file}", file=sys.stderr)
            return 1
    except Exception as e:
        print(f"Error reading pkgnames file: {e}", file=sys.stderr)
        return 1
    
    try:
        repos = read_lines_from_file(options.repos_file)
        if not repos:
            print(f"Error: No repositories found in file: {options.repos_file}", file=sys.stderr)
            return 1
    except Exception as e:
        print(f"Error reading repos file: {e}", file=sys.stderr)
        return 1
    
    # Create database connection and query manager
    query_manager = QueryManager(options.sql_dir)
    
    database = Database(options.dsn, query_manager, readonly=True, application_name='repology-query')
    
    # Query database for packages
    packages = database.query_by_visiblenames(visiblenames=pkgnames, repos=repos)
    
    # Group by effname and repo
    packages_by_effname_repo = defaultdict(lambda: defaultdict(list))
    effnames = set()
    found_visiblenames = set()
    
    for package in packages:
        effname = package['effname']
        repo = package['repo']
        visiblename = package['visiblename']
        
        packages_by_effname_repo[effname][repo].append(visiblename)
        effnames.add(effname)
        found_visiblenames.add(visiblename)
    
    # Identify packages that weren't found in any repository
    not_found = [name for name in pkgnames if name not in found_visiblenames]

    # For not found packages, try deeper search in binname and binnames
    if not_found:
        print(f"Searching for {len(not_found)} packages in binnames...")
        depth_packages = database.query_by_binnames(visiblenames=not_found, repos=repos)
        
        # Process depth query results
        depth_found = set()
        for package in depth_packages:
            effname = package['effname']
            repo = package['repo']
            visiblename = package['visiblename']
            
            # Mark it as found via binname with an asterisk
            found_via = package['binname'] if package['binname'] in not_found else "binnames array"
            modified_name = f"{visiblename} (found via {found_via}*)"
            
            packages_by_effname_repo[effname][repo].append(modified_name)
            effnames.add(effname)
            depth_found.add(found_via)
        
        # Update not_found list
        not_found = [name for name in not_found if name not in depth_found]
    
    # Prepare data for table writer
    headers = ["project"] + repos
    value_matrix = []
    
    for effname in sorted(effnames):
        row = [effname]
        
        for repo in repos:
            visiblenames = packages_by_effname_repo[effname].get(repo, [])
            if visiblenames:
                cell_content = "<br>".join(visiblenames)
            else:
                cell_content = ""
            row.append(cell_content)
        
        value_matrix.append(row)
    
    # Create result directory if it doesn't exist
    os.makedirs("result", exist_ok=True)
    
    # Create writer instance
    writer = MarkdownTableWriter(
        headers=headers,
        value_matrix=value_matrix,
        margin=1  # add a space for better readability
    )
    
    # Write the table to a file
    with open("result/table.md", "w") as f:
        writer.stream = f
        writer.write_table()
    
    # Write not found packages to a file
    if not_found:
        with open("result/not_found.txt", "w") as f:
            for name in sorted(not_found):
                f.write(f"{name}\n")
    else:
        # Create an empty file even if all packages were found
        open("result/not_found.txt", "w").close()
    
    print(f"Results written to result/table.md")
    print(f"Not found packages written to result/not_found.txt")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
