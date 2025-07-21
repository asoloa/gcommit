# Description
These scripts use GPT-4.1 to automatically generate conventional commit messages based on your staged & unstaged changes.

```bash
$ gcommit.sh --help
Generates a commit message based on all changes (both staged and unstaged) since the last commit.

Options:
  -a, --auto       Run in automatic mode (no user prompts)
  -s, --staged     Process staged changes only
  -h, --help       Show this help message and exit

Arguments:
  FILE             Text file where the commit message will be stored (defaults to './.commit-msg.txt')

Defaults:
If "-s|--staged" is not used, all changes (staged and unstaged) will be processed.
If FILE exists and is not empty, its contents will be overwritten with the generated commit message.
```

`gcommit-hook.sh` - same as `gcommit.sh` without the user prompts and options. This only detects the staged changes and can be used as a custom script for your project's `prepare-commit-message` hook.

`gcommit_tokenize.py` - uses `tiktoken` to determine the tokens to be consumed by the input prompt (context + `git diff` output)

&nbsp;
# Requirements
These tools are developed and tested in an AlmaLinux environment, but should work in Red Hat, CentOS, and Rocky Linux.
### API Requirements
These scripts use OpenAI APIs. Store your API key in the `OPENAI_API_KEY` environment variable.
### Software Requirements
- Python >= 3.9
- tiktoken (`pip install tiktoken`)
- openai (`pip install openai`)
- git
- curl
- jq

&nbsp;
# Installation
Clone repository:
```bash
git clone https://github.com/asoloa/gcommit.git ~/.gcommit
echo "export GCOMMIT_DIR=~/.gcommit" >> ~/.bashrc
source ~/.bashrc
```

### Setting custom script for `prepare-commit-message` hook
Create a symbolink link of `gcommit-hook.sh` to your project's `prepare-commit-message` hook:
```bash
cd <project>/.git/hooks
ln -s ~/.gcommit/gcommit-hook.sh prepare-commit-message
 ```
As this script only trackes staged changes, make sure you have already staged your to-be-committed changes via `git add`.

After staging your changes, execute `git commit`.

### Setting `gcommit` script
Create a symbolink link of `gcommit.sh` to `/usr/bin/gcommit` script (make sure you have `sudo` privileges and `/usr/bin/gcommit` is not already in use):
```bash
cd /usr/bin
ln -s ~/.gcommit/gcommit.sh gcommit
```
Now you can use `gcommit` anywhere in your terminal.