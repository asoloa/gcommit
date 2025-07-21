#!/usr/bin/python3

import tiktoken
import argparse

ap = argparse.ArgumentParser()

ap.add_argument("-t", "--text", required=True, help="Text to tokenize")
args = vars(ap.parse_args())

# gcommit.sh uses GPT-4.1, but as of now, tiktoken does not support GPT-4.1 model yet
# based on the discussion below, GPT-4.1 uses the same tokenization algorithm as GPT-4o
# https://community.openai.com/t/whats-the-tokenization-algorithm-gpt-4-1-uses/1245758
print(len(tiktoken.encoding_for_model("gpt-4o").encode(args['text'])))