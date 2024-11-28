# ~/.zsh_functions/git_unstage.zsh

# Function to interactively select multiple staged files and unstage them using fzf
# If the first argument is "all", unstage all staged files without prompting
# Accepts an optional file extension (e.g., "cs", "json", "yaml")
gunstage() {
  local -a selected_files
  local repo_root file_extension="$1"
  local unstage_all=false

    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

  # Navigate to the repository root to ensure consistent path handling
  dirs -c
  pushd "$repo_root" > /dev/null || return 1

  # Check if the first argument is "all"
  if [[ "$1" == "all" ]]; then
    unstage_all=true
    file_extension="$2"  # Shift the file extension if provided
  fi

  if $unstage_all; then
    # Unstage all staged files
    echo "Unstaging all staged files..."

    # Determine the repository root
    export repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo "Error: Not inside a Git repository."
      return 1
    fi

    # Retrieve all staged files
    if [[ -n "$file_extension" ]]; then
      selected_files=($(git diff --name-only --cached | grep "\.${file_extension}$"))
    else
      selected_files=($(git diff --name-only --cached))
    fi

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
    git restore --staged -- "${selected_files[@]}"

    # Alternative for older Git versions:
    # git reset HEAD -- "${selected_files[@]}"

    # Check if the git restore command was successful
    if [[ $? -eq 0 ]]; then
      echo "Successfully unstaged all files."
    else
      echo "Failed to unstage some or all files."
    fi
  else
    # Interactive selection to unstage specific files
    if [[ -n "$file_extension" ]]; then
      selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to unstage" "$file_extension")}")
    else
      selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to unstage")}")
    fi

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
    git restore --staged -- "${selected_files[@]}"

    # Alternative for older Git versions:
    # git reset HEAD -- "${selected_files[@]}"

    # Check if the git restore command was successful
    if [[ $? -eq 0 ]]; then
      echo "Successfully unstaged the selected file(s)."
    else
      echo "Failed to unstage some or all selected files."
    fi
  fi

  # Return to the original directory
  if [[ $(dirs -v | wc -l) -gt 1 ]]; then
      popd > /dev/null || return 1
  fi
}
