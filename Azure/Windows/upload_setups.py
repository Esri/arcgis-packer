#!/usr/bin/env python

"""
   Copyright 2019 Esri

   Licensed under the Apache License, Version 2.0 (the "License");

   you may not use this file except in compliance with the License.

   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software

   distributed under the License is distributed on an "AS IS" BASIS,

   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

   See the License for the specific language governing permissions and

   limitations under the License.​
"""

import os
import sys
import argparse
import json
import subprocess
from typing import List
from azure.storage.file import FileService


def _arg_parser():
    parser = argparse.ArgumentParser(description="Steps to check for and gather setups")
    parser.add_argument("--config-file-path", default=None, help="Configuration File Path")
    parser.add_argument("--afs-storage-account", default=None, help="AFS Storage Account Name")
    parser.add_argument("--afs-storage-account-key", default=None, help="AFS Storage Account Key")
    parser.add_argument("--afs-name", default=None, help="AFS Name")
    parser.add_argument("--afs-endpoint-suffix", default="core.windows.net", help="AFS Endpoint Suffix")
    #parser.add_argument("--azcopy-path", default="windows", help="azcopy v10 exe")
    #parser.add_argument("--afs-sas-uri", default="windows", help="AFS SAS URI")
    parser.add_argument(
        "--ignore",
        nargs="*",
        default=[],
        help="Space separated list of setups to ignore from config",
    )
    return parser.parse_args()


def _check_setups_local(setups: List, ignore: List[str]) -> bool:
    """
    Checks if all setups specified in config.py are available.
    """
    missing_setups = []
    missing_patches = []
    for setup in setups:
        print("Checking for {} located at {}".format(setup['Name'], setup['SourcePath']))
        if not os.path.exists(setup['SourcePath']):
            if not ignore:
                missing_setups.append(setup)
            elif not any(setup['Name'] in s for s in ignore):
                missing_setups.append(setup)
        else:
            if setup['IsMsi'] is False:
                for patch in setup['Patches']:
                    print("Checking for patch for {} located at {}".format(setup['Name'], patch))
                    if not os.path.exists(patch):
                        missing_patches.append({"InstallerName": setup['Name'],"PatchPath": patch})
    if missing_setups or missing_patches:
        if missing_setups:
            print("Missing {} setups: {} ".format(len(missing_setups), missing_setups))
        if missing_patches:
            print("Missing {} patches: {} ".format(len(missing_patches), missing_setups))
        return False
    else:
        print("All setups and patches are available.")
        return True


def _main(args):
    with open(args.config_file_path) as data_file:
        file_service = FileService(account_name=args.afs_storage_account, account_key=args.afs_storage_account_key,endpoint_suffix=args.afs_endpoint_suffix)
        config_json = json.load(data_file)
        if _check_setups_local(config_json['Installers'], args.ignore):
            for installer in config_json['Installers']:
                print("Uploading {} to AFS ".format(installer['SourcePath']))
                file_service.create_file_from_path(args.afs_name, None, installer['RemotePath'], installer['SourcePath'])
                if installer['IsMsi'] is False:
                    for patch in installer['Patches']:
                        patch_file_name = os.path.basename(patch)
                        print("Uploading {} to AFS ".format(patch_file_name))
                        file_service.create_file_from_path(args.afs_name, None, patch_file_name, patch)
                #archive_command = r'"{}" cp {} {}'.format(args.azcopy_path, installer['SourcePath'], args.afs_sas_uri)
                #print(archive_command)
                #subprocess.call(archive_command, shell=True)
        else:
            sys.exit(1)


if __name__ == "__main__":
    sys.exit(_main(_arg_parser()))
    