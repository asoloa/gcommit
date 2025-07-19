#!/usr/bin/python3

import tiktoken
import argparse

ap = argparse.ArgumentParser()

ap.add_argument("-t", "--text", required=True, help="Text to tokenize")
args = vars(ap.parse_args())

print(len(tiktoken.encoding_for_model("gpt-4o").encode(args['text'])))