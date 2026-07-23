#!/usr/bin/python
# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os

DOCUMENTATION = r'''
---
module: my_own_module
short_description: Creates a text file with specified content
version_added: "1.0.0"
description: Creates a file at the given path with the specified content.
options:
    path:
        description: Target file path on the remote host.
        required: true
        type: str
    content:
        description: Content to write into the file.
        required: true
        type: str
author:
    - Oleg (@olegkomel1-del)
'''

EXAMPLES = r'''
- name: Create a file with custom content
  my_own_module:
    path: /tmp/testfile.txt
    content: "Hello from my custom module!"
'''

RETURN = r'''
path:
    description: Path of the target file.
    type: str
    returned: always
content:
    description: Content written to the file.
    type: str
    returned: always
'''

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        path='',
        content=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']
    result['path'] = path
    result['content'] = content

    file_exists = os.path.exists(path)
    current_content = ""
    if file_exists:
        with open(path, 'r') as f:
            current_content = f.read()

    if not file_exists or current_content != content:
        result['changed'] = True

    if module.check_mode:
        module.exit_json(**result)

    if result['changed']:
        try:
            with open(path, 'w') as f:
                f.write(content)
        except Exception as e:
            module.fail_json(msg=f"Failed to write file: {str(e)}", **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
