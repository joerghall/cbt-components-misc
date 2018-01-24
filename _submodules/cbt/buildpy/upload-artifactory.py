#!/usr/bin/env python
# MIT License
#
# Copyright (c) 2018 Joerg Hallmann
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# https://github.com/joerghall/cbt
#
from __future__ import print_function

import argparse
import os
import os.path
import re
import requests
import sys

SCRIPT_PATH = os.path.realpath(__file__)

def upload(package_path, url, apiuser, apikey):

    print("Starting upload {0} to {1}".format(package_path, url))

    parameters = {"publish": "1", "override": "1"}

    with open(package_path, "rb") as fp:
        response = requests.put(url, auth=(apiuser, apikey), params=parameters, data=fp)

    if response.status_code != 201:
        raise RuntimeError("Uploading package {0} to {1} - code: {2} msg: {3}".format(package_path, url, response.status_code, response.text))
    else:
        print("Completed uploading package {0} to {1}".format(package_path, url))

def main_inner(args):

        if args.apiuser:
            print("API key provided")
        elif args.apiuser is None and "apiuser" in os.environ:
            args.apiuser = os.environ["apiuser"]
        else:
            raise RuntimeError("No apiuser provided")

        if args.apipwd:
            print("API pwd provided")
        elif args.apipwd is None and "apipwd" in os.environ:
            args.apipwd = os.environ["apipwd"]
        else:
            raise RuntimeError("No apipwd provided")

        file = args.file
        url = args.url

        upload(file, url, args.apiuser, args.apipwd)

def main():

    parser = argparse.ArgumentParser(description="Upload to artifactory")
    parser.add_argument("--file", help="package path to upload", type=os.path.abspath)
    parser.add_argument("--url", help="url to upload")
    parser.add_argument("--apiuser", default=None, help="API user")
    parser.add_argument("--apipwd", default=None, help="API pwd")

    args = parser.parse_args()

    result = main_inner(args)
    if result is None:
        sys.exit(0)
    else:
        sys.stderr.write("{} validation errors were detected.\n".format(len(result)))
        for error in result:
            sys.stderr.write("  {}\n".format(error))
        sys.exit(1)

if __name__ == "__main__":
    main()
