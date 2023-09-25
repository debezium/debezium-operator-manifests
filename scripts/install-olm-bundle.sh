#! /usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/functions.sh"
checkDependencies

OPTS=`getopt -o v:i:u:f --long version:,input:,input-url:,force,push,commit -n 'parse-options' -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

# Set defaults
OUTPUT_DIR_BASE="$SCRIPT_DIR/../olm/bundles"
FORCE=false
TMP_WORKDIR=$(mktemp -d)
COMMIT=false
PUSH=false

# Process script options
while true; do
  case "$1" in
    -v | --version )            BUNDLE_VERSION=$2;                  shift; shift ;;
    -i | --input )              INPUT_FILE=$2;                      shift; shift ;;
    -u | --input-url )          INPUT_URL=$2;                       shift; shift ;;
    -f | --force )              FORCE=true;                         shift ;;
    --commit )                  COMMIT=true;                        shift ;;
    --push )                    COMMIT=true;
                                PUSH=true;                          shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [[ ! -d "$OUTPUT_DIR_BASE" ]]; then
  echo "Output directory $OUTPUT_DIR_BASE does not exist!"
  exit 1
fi

# Set variables
OUTPUT_DIR="$OUTPUT_DIR_BASE/$BUNDLE_VERSION"

echo ""
echo "Installing OLM bundle"
echo "Bundle output dir: $OUTPUT_DIR"
echo ""

if [[ -d "$OUTPUT_DIR" && "$FORCE" = true ]]; then
  echo "Removing exiting bundle directory '$OUTPUT_DIR'"
  rm -rf "$OUTPUT_DIR"
fi


if [[ -d "$OUTPUT_DIR" ]]; then
  echo "Directory $OUTPUT_DIR already exists!"
  echo "Use -f / --force to overwrite"
  exit 2
fi

if [[ ! -z "${INPUT_URL:-}" ]]; then
  INPUT_FILE="$TMP_WORKDIR/bundle.zip"
  echo "Downloading bundle archive to '$INPUT_FILE'"
  curl -js -o "$INPUT_FILE" "$INPUT_URL"
fi

# Unzip $INPUT_INPUT_FILE and move bundle to $OUTPUT_OUTPUT_DIR
echo "Extracting and moving bundle archive to '$OUTPUT_DIR'"
unzip -qd "$TMP_WORKDIR" "$INPUT_FILE"
mv "$TMP_WORKDIR"/debezium-operator.v* "$OUTPUT_DIR"

# Remove temporary work directory
if [[ -d "$TMP_WORKDIR" ]]; then
  rm -rf "$TMP_WORKDIR"
fi


if [[ "$COMMIT" = true ]]; then
    echo ""
    echo "Committing bundle to repository"
    git commit -m "operator debezium-operator ($BUNDLE_VERSION)"
fi

if [[ "$PUSH" = true ]]; then
    echo ""
    echo "Pushing changes to remote repository"
    git push
fi