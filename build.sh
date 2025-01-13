#!/bin/bash

set -e
set -o pipefail

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory for the site sources
TARGET_DIR="$SCRIPT_DIR/training-slicer-org"

# Settings for building the site
CONFIG_OPTS="_config.yml,$SCRIPT_DIR/_config_training.yml"

err() { echo -e >&2 "ERROR: $@\n"; }
die() { err "$@"; exit 1; }

# Help message
show_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --target-source-dir PATH       Directory for preparing source files into (default: $TARGET_DIR)."
  echo "  --prepare                      Prepare the environment by cloning, setting up files and skipping cleanup."
  echo "  --slicer-org-checkout SHA      Checkout slicer.org repository to the specified commit SHA."
  echo "  --slicer-org-source-dir PATH   Use an existing slicer.org source directory instead of cloning the repo."
  echo "  --build                        Build the site locally into the '_site' directory using Jekyll (implies --prepare)."
  echo "  --serve                        Build and serve the site locally using Jekyll (implies --prepare)."
  echo "  --skip-cleanup                 Skip removal of target directory (default: $TARGET_DIR)."
  echo "  --extra-config PATH1[,PATH2]   Path of additional config files to associate with the --config Jekyll option."
  echo "  -h, --help                     Show this help message and exit."
}

# Argument default values
BUILD=false
SERVE=false
SLICER_ORG_SHA=""
SLICER_ORG_SOURCE_DIR="" # Custom "slicer.org" source directory
CLEANUP=true # Flag to track if copied files should be removed on exit
PREPARE=false
EXTRA_CONFIG_OPTS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --target-source-dir)
      shift
      TARGET_DIR="$(realpath "$1")"  # Get absolute path to avoid issues
      ;;
    --prepare)
      PREPARE=true
      ;;
    --slicer-org-checkout)
      shift
      SLICER_ORG_SHA="$1"
      ;;
    --slicer-org-source-dir)
      shift
      SLICER_ORG_SOURCE_DIR="$(realpath "$1")"  # Get absolute path to avoid issues
      ;;
    --build)
      BUILD=true
      ;;
    --serve)
      SERVE=true
      ;;
    --skip-cleanup)
      CLEANUP=false
      ;;
    --extra-config)
      shift
      EXTRA_CONFIG_OPTS="$1"
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      show_help
      exit 1
      ;;
  esac
  shift
done

if $PREPARE; then
  CLEANUP=false
fi

if [[ "$BUILD" == true && "$SERVE" == true ]]; then
  die "Options --build and --serve are mutually exclusive."
fi

if [[ "$PREPARE" != true && "$BUILD" != true && "$SERVE" != true ]]; then
  die "At least one of these options should be specified: --prepare, --build or --serve."
fi

prepare_environment() {
  echo "Preparing environment..."

  github_short_sha=$(git -C "$SCRIPT_DIR" rev-parse --short HEAD)
  echo "training.slicer.org version is $github_short_sha"

  mkdir -p "$TARGET_DIR"
  echo "github_short_sha: ${github_short_sha}" > $TARGET_DIR/_config_training_revision.yml

  CONFIG_OPTS="$CONFIG_OPTS,_config_training_revision.yml"
  
  # Determine if using a source directory or cloning the repository
  if [[ -n "$SLICER_ORG_SOURCE_DIR" ]]; then
    if [[ ! -d "$SLICER_ORG_SOURCE_DIR" ]]; then
      die "Source directory $SLICER_ORG_SOURCE_DIR does not exist"
    fi
  else
    source_dir="$SCRIPT_DIR/slicer-org"
    cloned=false

    # Clone the repository if it does not exist
    if [[ ! -d "$source_dir" ]]; then
      echo "Cloning slicer.org repository..."
      git clone --depth 1 https://github.com/Slicer/slicer.org.git "$source_dir"
      cloned=true
    else
      echo "Repository already exists. Skipping clone."
    fi

    # Ensure the repository directory exists before proceeding
    if [[ ! -d "$source_dir" ]]; then
      die "$source_dir directory does not exist"
    fi

    # Perform checkout if explicitly requested or if the repo was freshly cloned
    if [[ -n "$SLICER_ORG_SHA" || "$cloned" == true ]]; then
      echo "Checking out commit: ${SLICER_ORG_SHA:-HEAD}"
      (cd "$source_dir" && git checkout "${SLICER_ORG_SHA:-HEAD}")
    fi

    SLICER_ORG_SOURCE_DIR="$source_dir"
  fi
}

prepare_environment

cleanup() {
  if $CLEANUP; then
    echo "Cleaning up..."
    echo "Removing: $TARGET_DIR"
    rm -rf "$TARGET_DIR"
  else
    echo "Skipping cleanup"
  fi
}

# Register cleanup function to execute on exit
trap cleanup EXIT

# List of files to copy
FILES_TO_COPY=(
  "$SCRIPT_DIR/training.markdown:$TARGET_DIR/training.markdown"
  "$SCRIPT_DIR/training.markdown:$TARGET_DIR/index.markdown"
  "$SCRIPT_DIR/_data/tutorials.yml:$TARGET_DIR/_data/tutorials.yml"
)

# Include all image assets
mkdir -p "$TARGET_DIR/assets/img"
for img in "$SCRIPT_DIR/assets/img/"*; do
  FILES_TO_COPY+=("$img:$TARGET_DIR/assets/img/$(basename "$img")")
done

# Include all files from slicer.org source directory
echo "Using source directory: $SLICER_ORG_SOURCE_DIR"
while IFS= read -r -d '' file; do
  relative_path="${file#$SLICER_ORG_SOURCE_DIR/}"  # Compute correct relative path
  dest="$TARGET_DIR/$relative_path"  # Use TARGET_DIR for destination
  mkdir -p "$(dirname "$dest")"  # Ensure target directories exist
  FILES_TO_COPY+=("$file:$dest")
done < <(find "$SLICER_ORG_SOURCE_DIR" -type f ! -path "$SLICER_ORG_SOURCE_DIR/.git/*" \
                                   ! -path "$SLICER_ORG_SOURCE_DIR/.jekyll-cache/*" \
                                   ! -path "$SLICER_ORG_SOURCE_DIR/.sass-cache/*" \
                                   ! -path "$SLICER_ORG_SOURCE_DIR/_site/*" \
                                   ! -name "index.markdown" \
                                   ! -name ".jekyll-metadata" -print0)

# Function to copy files only if modified
copy_files() {
  IFS=";" read -ra FILES <<< "$FILES_TO_COPY_STRING"
  for file_pair in "${FILES[@]}"; do
    src="${file_pair%%:*}"
    dest="${file_pair##*:}"

    if [[ -f "$dest" && -e "$src" ]]; then
      if cmp -s "$src" "$dest"; then
        continue
      fi
    fi

    echo "Copying: $src -> $dest"
    cp "$src" "$dest"
  done
}

# Export function and array as a string
export -f copy_files
export FILES_TO_COPY_STRING="$(IFS=";"; echo "${FILES_TO_COPY[*]}")"

# If serving mode is enabled, check if `entr` is available
if $SERVE; then
  if command -v entr &> /dev/null; then
    echo "Using entr to watch for file changes while serving..."
    (printf "%s\n" "${FILES_TO_COPY[@]%%:*}" | entr bash -c "copy_files") &  # Start entr in the background
  else
    echo "entr not found. Falling back to one-time file copy."
    copy_files
  fi
else
  echo "Serve mode not enabled. Copying files once..."
  copy_files
fi

if $SERVE; then
  PORT=4000 # Also hard-coded in "$TARGET_DIR/_config_dev.yml"

  # Serve the site if --serve is passed
  echo "Starting Jekyll server on port $PORT..."
  (cd "$TARGET_DIR" && \
   bundle exec jekyll serve -d "$SCRIPT_DIR/_site" \
     --config "$CONFIG_OPTS,$TARGET_DIR/_config_dev.yml,$EXTRA_CONFIG_OPTS" \
     --watch --force_polling \
     -H 0.0.0.0 -P "$PORT" \
     --incremental)
elif $BUILD; then
  # Build the site by default
  echo "Building the site..."
  (cd "$TARGET_DIR" && \
   bundle exec jekyll build -d "$SCRIPT_DIR/_site" \
     --config "$CONFIG_OPTS,$EXTRA_CONFIG_OPTS")
fi
