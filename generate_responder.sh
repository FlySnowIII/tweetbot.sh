#!/usr/bin/env bash

work_dir="$(pwd)"
tools_dir="$(cd "$(dirname "$0")" && pwd)"
tweet_sh="$tools_dir/tweet.sh/tweet.sh"

source "$tweet_sh"

if [ "$TWEET_BASE_DIR" != '' ]
then
  TWEET_BASE_DIR="$(cd "$TWEET_BASE_DIR" && pwd)"
else
  TWEET_BASE_DIR="$work_dir"
fi

responder="$TWEET_BASE_DIR/responder.sh"

echo 'Generating responder script...' 1>&2
echo "  sources: $TWEET_BASE_DIR/responses" 1>&2
echo "  output : $responder" 1>&2

cat << FIN > "$responder"
#!/usr/bin/env bash
#
# This file is generated by "generate_responder.sh".
# Do not modify this file manually.

base_dir="\$(cd "\$(dirname "\$0")" && pwd)"

input="\$(cat)"

extract_response() {
  local source="\$1"
  local responses="\$(cat "\$source" |
                        grep -v '^#' |
                        grep -v '^\s*\$')"
  local n_responses="\$(echo "\$responses" | wc -l)"
  local index=\$(((\$RANDOM % \$n_responses) + 1))
  echo "\$responses" | sed -n "\${index}p"
}

FIN

cd "$TWEET_BASE_DIR"

ls ./responses/* |
  sort |
  while read path
do
  matcher="$(\
    # first, convert CR+LF => LF
    nkf -Lu "$path" |
      # extract comment lines as definitions of matching patterns
      grep '^#' |
      # remove comment marks
      sed -e 's/^#\s*//' \
          -e '/^\s*$/d' |
      # concate them to a list of patterns
      paste -s -d '|')"
  cat << FIN >> "$responder"
if echo "\$input" | egrep -i "$matcher" > /dev/null
then
  extract_response "\$base_dir/$path"
  exit 0
fi

FIN
done

last_file="$(ls ./responses/* |
               sort |
               tail -n 1)"
if [ -f "$last_file" ]
then
  cat << FIN >> "$responder"
# fallback to the last pattern
extract_response "\$base_dir/$last_file"
exit 0
FIN
else
  cat << FIN >> "$responder"
echo ""
exit 1
FIN

chmod +x "$responder"