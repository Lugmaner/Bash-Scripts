#!/usr/bin/bash

date_time=$(date)
if test $# -ne 1; then
    echo "Usage $0 PLUGIN_NAME" >&2
    exit 1
fi

pname="$1"
script_dir="$(cd "$(dirname "$0")" && pwd)"
call_dir="$PWD"
input_dir="$script_dir/input"

if test -e "$call_dir/$pname"; then
    echo "Error: plugin named $pname already exists" >&2
    exit 1
fi

mkdir "$call_dir/$pname"
mkdir "$call_dir/$pname/bin" "$call_dir/$pname/logs" "$call_dir/$pname/src" "$call_dir/$pname/resources"
touch "$call_dir/$pname/logs/setup.log"

echo "Creating plugin $pname at $date_time" >> "$call_dir/$pname/logs/setup.log"

sed "s/#PLUGIN_NAME#/$pname/g" "$input_dir/Makefile" > "$call_dir/$pname/Makefile"
sed "s/#PLUGIN_NAME#/$pname/g" "$input_dir/README" > "$call_dir/$pname/README"

for f in "$input_dir"/resources/*; do
    if test ! -f "$f"; then
        continue
    else
        name=$(basename "$f")
        sed "s/#PLUGIN_NAME#/$pname/g" "$f" > "$call_dir/$pname/resources/$name"
    fi
done

for f in "$input_dir"/src/*; do
    if test ! -f "$f"; then
        continue
    else
        name=$(basename "$f")
        sed "s/#PLUGIN_NAME#/$pname/g" "$f" > "$call_dir/$pname/src/$name"
    fi
done

for f in "$call_dir/$pname"/resources/*.sh; do
    if test ! -e "$f"; then
        continue
    fi
    name=$(basename "$f")
    if test "$(head -n 1 "$f")" != "#!/bin/bash"; then
        echo "Error: resource script $name does not start with #!/bin/bash" >> "$call_dir/$pname/logs/setup.log"
        echo "Error: resource script $name does not start with #!/bin/bash" >&2
    else
        chmod 744 "$f"
    fi
done
echo "The following initial directory structure was created:" >> "$call_dir/$pname/logs/setup.log"
ls -R "$call_dir/$pname" >> "$call_dir/$pname/logs/setup.log"
exit 0
