#!/bin/bash

set -o pipefail

###############################################################################
#                           Public functions                                  #
###############################################################################


# Extract a value from an cfg file input stream
# given the names of the section and key as parameters
extract_cfg_value() {
  local section=$1
  local key=$2
  # The grep command uses the technique described here:
  # https://unix.stackexchange.com/a/13472
  # I added -m1 to limit to first match. Thus if the cfg
  # file has multiple entries for a key, the first will win.
  # This is how ~/.ssh/config acts, so I think this is a reasonable
  # design decision.
  # grep, as usual, will exit with non-zero exit status if no match is found.
  # That's good. That's how the caller can differentiate between no match
  # and a successfuly match with value of empty string.
  # Just be sure to set the pipefail option.
  # The output of the grep stage still includes any trailing white space.
  # The final sed stage removes any trailing white space.
  _remove_comment_lines \
    | _process_any_line_continuations \
    | _extract_cfg_section "$section" \
    | grep -Po -m1 '^'"$key"'\s*=\s*\K.*' | sed -E 's/\s+$//'
}

###############################################################################
#                           Private functions                                 #
###############################################################################


# The systemd config file syntax treats lines beginning with '#' or ';' 
# as comment lines
_remove_comment_lines() {
  awk '
/^#/ {next;}     # ignore lines that start with a pound sign
/^;/ {next;}     # ignore lines that start with a semicolon
{print}
'
}

# The systemd config file syntax supports using backslash as a line
# continuation character. This can be done with sed:
# https://unix.stackexchange.com/a/13704 Same answer here:
# https://unix.stackexchange.com/a/146864 which is from #39 here:
# https://catonmat.net/sed-one-liners-explained-part-one
_process_any_line_continuations() {
  sed ':x; /\\$/ { N; s/\\\n//; tx }'
}

# Extract the contents of a particular cfg section.
# This is based on the non-inclusive awk example here:
# https://unix.stackexchange.com/a/264972
_extract_cfg_section() {
  local section=$1
  if [[ -n $section ]]; then
    awk '/^\['"$section"'\]$/{flag=1;print;next}/^\[[[:alnum:][:blank:]]*\]$/{flag=0}flag'
  else
    awk 'NR==1{flag=1;print;next}/^\[[[:alnum:][:blank:]]*\]$/{flag=0}flag'
  fi
}
