#!/bin/sh

fzf_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${fzf_revamped_dir}/bin/fzf-revamped" apply
