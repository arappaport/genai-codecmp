#!/usr/bin/env bash
#
# pyquality.sh — Run pylint on files matching a glob pattern and show scores
#
# Usage:
#   ./pyquality.sh "*.py"
#
# Works in bash and zsh

#set -euo pipefail

# --- Functions ---
usage() {
    echo "Usage: $0 <--csv> <--debug> <fpattern>"
    echo "Example: $0 \"*.py\""

    echo "Generates a table of scores."
    echo " --csv - all output in csv.   "

    echo "Columns: "
    echo " - lines - total lines including comments (wc)"
    echo " - lines_src - Number of lines containing source code. Uses SLOC from radom raw"
    echo " - lines_comments - total lines of python source.  Uses Comments from radom raw"
    echo " - pylint - pylint score "
    echo " - flake: "
    echo " - radon_cc: Radon code complexity"
    echo " - radon_mi: Radon code maintainability"
    echo " - bandit_sev: Bandit.  Lists count of High,Medium and Low severity findings."
    echo " - MyPy: Mypy # of errors found. Lower is better."
    printf "$PRINT_FORMAT" "File Name" "Pylint" "Flake8" "radon_cc"  "radon_mi"    "bandit_sev" "MyPy_errs"
    exit 1
}

# --- Validate arguments ---
if [[ $# -eq 0 ]]; then
    usage
fi

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Check for required tools
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it using 'pip install $1'."
        exit 1
    fi
}
check_tool pylint
check_tool flake8
check_tool mypy
check_tool black
check_tool radon
check_tool coverage

fpattern="$1"

# Enable nullglob so unmatched patterns don't remain literal
if [[ -n "${BASH_VERSION:-}" ]]; then
    shopt -s nullglob
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    setopt NULL_GLOB
fi

#process optional parameters
# --- Initialize flags ---
csv_mode=false
verbose_mode=false
debug_mode=false
x_value=""

#Column seperator
sep="|"
# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --csv)
      csv_mode=true
      shift
      ;;
    --verbose)
      verbose_mode=true
      shift
      ;;
    --debug)
      debug_mode=true
      shift
      ;;
    --*)
      echo "Error: Unknown option '$1'"
      usage
      ;;
    *)
      if [ -z "$x_value" ]; then
        x_value="$1"
        shift
      else
        echo "Error: Unexpected extra argument '$1'"
        usage
      fi
      ;;
  esac
done

# --- Debug output ---
if $debug_mode; then
  echo "[DEBUG] x_value='$x_value'"
  echo "[DEBUG] csv_mode=$csv_mode"
  echo "[DEBUG] verbose_mode=$verbose_mode"
fi

# --- Output ---
if $csv_mode; then
  echo "$x_value"
else
  echo "csv mode: $x_value"
fi

# --- Verbose output ---
if $verbose_mode; then
  echo "Verbose mode enabled. You passed '$x_value' as the main value."
fi

# Expand the pattern into an array of files
files=( $x_value )

if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files matched pattern: $fpattern"
    exit 2
fi

# line format.   #10 column names. keep this in sync with printf got header and each row.
if [[ "$csv_mode" == "true" ]]; then
      #           1  2  3  4  5  6   7  8  9 10
    PRINT_FORMAT="%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n"
else
    #                  1   2   3    4   5   6     7     8    9  10
    PRINT_FORMAT="|%-48s |%5s|%9s|%14s|%6s|%8s|%8s|%8s|%9s|%26s|\n"
fi

#10 column names 0 keep this in sync with PRINT_FORMAT.
#                          1           2       3            4              5        6         7            8          9             10
printf "$PRINT_FORMAT" "File Name" "lines" "lines_src" "lines_comments" "Pylint" "Flake8" "radon_cc"  "radon_mi"   "MyPy_errs"   "bandit_sev"
#TODO - printf "$PRINT_FORMAT" "$(printf '%.0s-' {1..40})" "$(printf '%.0s-' {1..6})"

# --- Process each file ---
#pre-csv for file in "${files[@]}"; do
for file in "${files[@]}"; do

    #lines
    lines_score=$(wc -l "$file" | awk '{print $1}')
    pylines_score=$(grep -vE '^\s*$|^\s*#' "$file" | wc -l)

    #Lines of code - we use radon
    output=$(radon raw  "$file" 2>/dev/null )
    lines_lloc=$(echo "$output" | grep LLOC | awk -F'LLOC: ' '{print $2}')
    lines_sloc=$(echo "$output" | grep SLOC | awk -F'SLOC: ' '{print $2}')
    lines_comments=$(echo "$output" | grep Comments | awk -F'Comments: ' '{print $2}')

    # pylint
    pylint_score=$(pylint --score y "$file" 2>/dev/null | awk '/Your code has been rated at/ { split($7, a, "/"); print a[1] }')

    # Flake8
    flake8_out=$(flake8 "$file" 2>/dev/null | wc -l)
    flake8_out=${flake8_out:-"0"}

    # Radon Cyclomatic Complexity
    radon_cc=$(radon cc -a "$file"  2>/dev/null | grep "Average complexity" |  sed -n 's/.*(\([^)]*\)).*/\1/p')
    radon_cc=${radon_cc:-"N/A"}

    # Radon Maintainability Index
    radon_mi=$(radon mi "$file" 2>/dev/null |  sed 's/.*- //')
    radon_mi=${radon_mi:-"N/A"}

    # Mypy - count errors
    mypy_out=$(mypy "$file"  | awk '/Found [0-9]+ error/ {print $2}')
    mypy_out=${mypy_out:-"0"}

    # Bandit - count by severity
    bandit_out=$(bandit --quiet "$file" | awk '
  /Severity: HIGH/ {high++}
  /Severity: MEDIUM/ {medium++}
  /Severity: LOW/ {low++}
  END {print "Hi:",high+0, "Med:",medium+0, "Low:",low+0}
')

    bandit_out=${bandit_out:-"0"}


    # xopy "$PRINT_FORMAT" "File Name" "lines"                "lines_src"     "lines_comments"               "Pylint"             "Flake8"            "radon_cc"         "radon_mi"               "MyPy_errs"    "bandit_sev"
    printf "$PRINT_FORMAT" "$file" "${lines_score:-N/A}" "${lines_sloc:-N/A}" "${lines_comments:-N/A}" "${pylint_score:-N/A}" "${flake8_out:-N/A}" "${radon_cc:-N/A}" "${radon_mi:-N/A}"  "${mypy_out:-N/A}" "${bandit_out:-N/A}"
done
