# ~/.zsh_functions/git_diff.zsh

# Function to interactively select multiple changed files and view their diffs using fzf
# Accepts an optional file extension (e.g., "cs", "json", "yaml")
gdf() {
  local -a selected_files
  local repo_root file_extension="$1"

  # Capture the selected files into an array
  if [[ -n "$file_extension" ]]; then
    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) for git diff" "$file_extension")}")
  else
    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) for git diff")}")
  fi

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
  git diff -- "${selected_files[@]}"
}
