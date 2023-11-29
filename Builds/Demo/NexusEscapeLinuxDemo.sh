#!/bin/sh
echo -ne '\033c\033]0;Nexus- Escape\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/NexusEscapeLinuxDemo.x86_64" "$@"
