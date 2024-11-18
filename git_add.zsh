# ~/.zsh_functions/git_add.zsh

# Function to interactively select multiple unstaged changed files and stage them using fzf
# Accepts an optional file extension (e.g., "cs", "json", "yaml")
gadd() {
  local -a selected_files
  local repo_root file_extension="$1"

  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)

# Navigate to the repository root to ensure consistent path handling
  pushd "$repo_root" > /dev/null || return 1

  # Capture the selected files into an array
  if [[ -n "$file_extension" ]]; then
    selected_files=("${(@f)$(git_select_files "unstaged" "Select file(s) to stage" "$file_extension")}")
  else
    selected_files=("${(@f)$(git_select_files "unstaged" "Select file(s) to stage")}")
  fi

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
  git add -- "${selected_files[@]}"

  # Check if the git add command was successful
  if [[ $? -eq 0 ]]; then
    echo "Successfully staged the selected file(s)."
  else
    echo "Failed to stage some or all selected files."
  fi

  # Return to the original directory
    popd > /dev/null || return 1
}
