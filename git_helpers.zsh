# Helper function to select files based on criteria
git_select_files() {
  local criteria="$1"
  local prompt="$2"
  local repo_root selected_files files

  # Determine the repository root
  repo_root=$(git rev-parse --show-toplevel)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  # Navigate to the repository root to ensure consistent path handling
  pushd "$repo_root" > /dev/null || return 1

  if [[ "$criteria" == "changed" ]]; then
    # List all changed files (both staged and unstaged)
    # This includes modified, added, deleted, renamed, and copied files
    files=($(git status --short | awk '{print $2}'))
  elif [[ "$criteria" == "staged" ]]; then
    # List all staged files
    files=($(git diff --name-only --cached))
  else
    echo "Error: Unknown criteria '$criteria'. Use 'changed' or 'staged'."
    popd > /dev/null
    return 1
  fi

  # Check if there are any files
  if (( ${#files[@]} == 0 )); then
    echo "No files available for the criteria '$criteria'."
    popd > /dev/null
    return 0
  fi

  # Use fzf to select multiple files
  selected_files=($(printf '%s\n' "${files[@]}" | fzf --multi --prompt="$prompt: " --height 40% --layout=reverse --info=inline))

  # If no files were selected, exit
  if (( ${#selected_files[@]} == 0 )); then
    echo ""
    popd > /dev/null
    return 0
  fi

  # Output selected files, each on a new line
  printf '%s\n' "${selected_files[@]}"

  # Return to the original directory
  popd > /dev/null
}

# Function to interactively select multiple changed files and stage them using fzf
gadd() {
  local -a selected_files
  local repo_root

  # Determine the repository root
  repo_root=$(git rev-parse --show-toplevel)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  # Capture the selected files into an array
  selected_files=("${(@f)$(git_select_files "changed" "Select file(s) to stage")}")

  # If no files were selected, exit
  if (( ${#selected_files[@]} == 0 )); then
    echo "No files selected for staging."
    return 0
  fi

  # Display the selected files
  echo "Staging the following file(s):"
  for file in "${selected_files[@]}"; do
    echo "- $file"
  done
  echo ""

  # Stage the selected files
  git -C "$repo_root" add -- "${selected_files[@]}"

  # Check if the git add command was successful
  if [[ $? -eq 0 ]]; then
    echo "Successfully staged the selected file(s)."
  else
    echo "Failed to stage some or all selected files."
  fi
}

# Function to interactively select multiple changed files and view their diffs using fzf
gdf() {
  local -a selected_files
  local repo_root

  # Determine the repository root
  repo_root=$(git rev-parse --show-toplevel)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  # Capture the selected files into an array
  selected_files=("${(@f)$(git_select_files "changed" "Select file(s) for git diff")}")

  # If no files were selected, exit
  if (( ${#selected_files[@]} == 0 )); then
    echo "No files selected for diff."
    return 0
  fi

  # Display the selected files
  echo "Showing diffs for the following file(s):"
  for file in "${selected_files[@]}"; do
    echo "- $file"
  done
  echo ""

  # Run git diff on the selected files
  git -C "$repo_root" diff -- "${selected_files[@]}"
}

# Function to interactively select multiple staged files and unstage them using fzf
# If the argument "all" is provided, unstage all staged files without prompting
gunstage() {
  local -a selected_files
  local repo_root

  # Determine the repository root
  repo_root=$(git rev-parse --show-toplevel)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  if [[ "$1" == "all" ]]; then
    # Unstage all staged files
    echo "Unstaging all staged files..."

    # Retrieve all staged files
    selected_files=($(git -C "$repo_root" diff --name-only --cached))

    # Check if there are any staged files
    if (( ${#selected_files[@]} == 0 )); then
      echo "No staged files to unstage."
      return 0
    fi

    # Display the files being unstaged
    echo "Unstaging the following file(s):"
    for file in "${selected_files[@]}"; do
      echo "- $file"
    done
    echo ""

    # Unstage all files
    git -C "$repo_root" restore --staged -- "${selected_files[@]}"

    # Alternative for older Git versions:
    # git -C "$repo_root" reset HEAD -- "${selected_files[@]}"

    # Check if the git restore command was successful
    if [[ $? -eq 0 ]]; then
      echo "Successfully unstaged all files."
    else
      echo "Failed to unstage some or all files."
    fi
  else
    # Interactive selection to unstage specific files
    # Capture the selected files into an array
    selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to unstage")}")

    # If no files were selected, exit
    if (( ${#selected_files[@]} == 0 )); then
      echo "No files selected for unstaging."
      return 0
    fi

    # Display the selected files
    echo "Unstaging the following file(s):"
    for file in "${selected_files[@]}"; do
      echo "- $file"
    done
    echo ""

    # Unstage the selected files
    git -C "$repo_root" restore --staged -- "${selected_files[@]}"

    # Alternative for older Git versions:
    # git -C "$repo_root" reset HEAD -- "${selected_files[@]}"

    # Check if the git restore command was successful
    if [[ $? -eq 0 ]]; then
      echo "Successfully unstaged the selected file(s)."
    else
      echo "Failed to unstage some or all selected files."
    fi
  fi
}
