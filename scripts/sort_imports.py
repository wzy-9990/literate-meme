#!/usr/bin/env python3
"""
Script to sort import and export directives alphabetically in Dart files.

This script sorts import/export statements while maintaining the proper grouping:
1. Dart core imports (dart:...)
2. Package imports (package:...)
3. Local imports (relative paths)
"""

import re
import sys
from pathlib import Path


def sort_directives_in_file(file_path):
    """
    Sort import and export directives in a Dart file while maintaining proper grouping.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        original_content = f.read()
    
    lines = original_content.splitlines(keepends=True)
    
    # Find import and export directives
    directive_pattern = re.compile(r'^(import|export)\s+.*')
    
    # Identify directive blocks
    directive_blocks = []
    current_block = []
    in_directive_block = False
    
    for i, line in enumerate(lines):
        if directive_pattern.match(line.strip()):
            if not in_directive_block:
                # If there are non-directive lines between directive groups, end the previous block
                if current_block:
                    directive_blocks.append((current_block, i - len(current_block)))
                    current_block = []
                in_directive_block = True
            current_block.append((i, line.strip()))
        else:
            if in_directive_block:
                # End of a directive block
                directive_blocks.append((current_block, i - len(current_block)))
                current_block = []
                in_directive_block = False
    
    # Add any remaining directives
    if current_block:
        directive_blocks.append((current_block, len(lines) - len(current_block)))
    
    # Sort each directive block
    modified_lines = lines[:]
    for directives, start_line_idx in directive_blocks:
        # Group directives by type: dart:, package:, relative
        dart_imports = []
        package_imports = []
        relative_imports = []
        
        for idx, line in directives:
            if 'dart:' in line:
                dart_imports.append((idx, line))
            elif 'package:' in line:
                package_imports.append((idx, line))
            else:
                relative_imports.append((idx, line))
        
        # Sort each group by the import/export statement
        dart_imports.sort(key=lambda x: x[1])
        package_imports.sort(key=lambda x: x[1])
        relative_imports.sort(key=lambda x: x[1])
        
        # Combine the sorted groups
        sorted_directives = dart_imports + package_imports + relative_imports
        
        # Update the lines
        for i, (original_idx, directive_line) in enumerate(sorted_directives):
            modified_lines[start_line_idx + i] = directive_line + '\n'
    
    # Join the lines back together
    new_content = ''.join(modified_lines)
    
    # Write back if content changed
    if original_content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Sorted directives in {file_path}")
        return True
    
    return False


def main():
    if len(sys.argv) < 2:
        print("Usage: python sort_imports.py <directory_or_file>")
        sys.exit(1)
    
    path = Path(sys.argv[1])
    
    if path.is_file() and path.suffix == '.dart':
        files = [path]
    elif path.is_dir():
        files = list(path.rglob('*.dart'))
    else:
        print(f"Path {path} is not a Dart file or directory")
        sys.exit(1)
    
    modified_count = 0
    for file_path in files:
        try:
            if sort_directives_in_file(file_path):
                modified_count += 1
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    print(f"Processed {len(files)} files, modified {modified_count} files")


if __name__ == '__main__':
    main()
