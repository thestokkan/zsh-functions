# ~/.zsh_functions/gcommit.zsh

# Function to interactively select staged files and commit them with a message
# Accepts an optional file extension (e.g., "cs", "json", "yaml")
gcommit() {
  local -a selected_files
  export repo_root file_extension="$1"
  local commit_message

  # Capture the selected files into an array
  if [[ -n "$file_extension" ]]; then
    selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to commit" "$file_extension")}")
  else
    selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to commit")}")
  fi

  # If no files were selected, exit
  if (( ${#selected_files[@]} == 0 )); then
    echo "No files selected for committing."
    return 0
  fi

  # Prompt for commit message
  read -p "Enter commit message: " commit_message

  if [[ -z "$commit_message" ]]; then
    echo "Commit message cannot be empty."
    return 1
  fi

  # Commit the selected files
  git commit -m "$commit_message" -- "${selected_files[@]}"

  # Check if the commit was successful
  if [[ $? -eq 0 ]]; then
    echo "Successfully committed the selected file(s)."
  else
    echo "Failed to commit the selected file(s)."
  fi
}
