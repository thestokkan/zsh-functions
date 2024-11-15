## ~/.zsh_functions/git_helpers.zsh
#
## Helper function to select files based on criteria and optional file extension
#git_select_files() {
#  local criteria="$1"
#  local prompt="$2"
#  local file_extension="$3"
#  local repo_root selected_files files all_option="ALL"
#
#  # Determine the repository root
#  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
#  if [[ $? -ne 0 ]]; then
#    echo "Error: Not inside a Git repository."
#    return 1
#  fi
#
#  # Navigate to the repository root to ensure consistent path handling
#  pushd "$repo_root" > /dev/null || return 1
#
#  if [[ "$criteria" == "changed" ]]; then
#    # List all changed files (both staged and unstaged)
#    # This includes modified, added, deleted, renamed, and copied files
#    if [[ -n "$file_extension" ]]; then
#      # Filter files by the provided extension
#      files=($(git status --short | awk '{print $2}' | grep "\.${file_extension}$"))
#    else
#      files=($(git status --short | awk '{print $2}'))
#    fi
#  elif [[ "$criteria" == "staged" ]]; then
#    # List all staged files
#    if [[ -n "$file_extension" ]]; then
#      # Filter staged files by the provided extension
#      files=($(git diff --name-only --cached | grep "\.${file_extension}$"))
#    else
#      files=($(git diff --name-only --cached))
#    fi
#  else
#    echo "Error: Unknown criteria '$criteria'. Use 'changed' or 'staged'."
#    popd > /dev/null
#    return 1
#  fi
#
#  # Check if there are any files
#  if (( ${#files[@]} == 0 )); then
#    echo "No files available for the criteria '$criteria'${file_extension:+ with extension '.$file_extension'}."
#    popd > /dev/null
#    return 0
#  fi
#
#  # Prepend the "ALL" option to the files list
#  # This allows users to select "ALL" to operate on all files without individual selection
#  local fzf_input
#  fzf_input=("$all_option" "${files[@]}")
#
#  # Use fzf to select multiple files
#  selected_files=($(printf '%s\n' "${fzf_input[@]}" | fzf --multi --prompt="$prompt: " --height 40% --layout=reverse --info=inline))
#
#  # Return to the original directory
#  popd > /dev/null
#
#  # Check if "ALL" was selected
#  for selected in "${selected_files[@]}"; do
#    if [[ "$selected" == "$all_option" ]]; then
#      # If "ALL" is selected, return all files
#      printf '%s\n' "${files[@]}"
#      return 0
#    fi
#  done
#
#  # If "ALL" was not selected, return the selected files
#  if (( ${#selected_files[@]} == 0 )); then
#    echo ""
#    return 0
#  fi
#
#  # Output selected files, each on a new line
#  printf '%s\n' "${selected_files[@]}"
#}
#
## Function to interactively select multiple changed files and stage them using fzf
## Accepts an optional file extension (e.g., "cs", "json", "yaml")
#gadd() {
#  local -a selected_files
#  local repo_root file_extension="$1"
#
#  # Capture the selected files into an array
#  if [[ -n "$file_extension" ]]; then
#    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) to stage" "$file_extension")}")
#  else
#    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) to stage")}")
#  fi
#
#  # If no files were selected, exit
#  if (( ${#selected_files[@]} == 0 )); then
#    echo "No files selected for staging."
#    return 0
#  fi
#
#  # Display the selected files
#  echo "Staging the following file(s):"
#  for file in "${selected_files[@]}"; do
#    echo "- $file"
#  done
#  echo ""
#
#  # Stage the selected files
#  git add -- "${selected_files[@]}"
#
#  # Check if the git add command was successful
#  if [[ $? -eq 0 ]]; then
#    echo "Successfully staged the selected file(s)."
#  else
#    echo "Failed to stage some or all selected files."
#  fi
#}
#
## Function to interactively select multiple changed files and view their diffs using fzf
## Accepts an optional file extension (e.g., "cs", "json", "yaml")
#gdf() {
#  local -a selected_files
#  local repo_root file_extension="$1"
#
#  # Capture the selected files into an array
#  if [[ -n "$file_extension" ]]; then
#    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) for git diff" "$file_extension")}")
#  else
#    selected_files=("${(@f)$(git_select_files "changed" "Select file(s) for git diff")}")
#  fi
#
#  # If no files were selected, exit
#  if (( ${#selected_files[@]} == 0 )); then
#    echo "No files selected for diff."
#    return 0
#  fi
#
#  # Display the selected files
#  echo "Showing diffs for the following file(s):"
#  for file in "${selected_files[@]}"; do
#    echo "- $file"
#  done
#  echo ""
#
#  # Run git diff on the selected files
#  git diff -- "${selected_files[@]}"
#}
#
## Function to interactively select multiple staged files and unstage them using fzf
## If the argument "all" is provided, unstage all staged files without prompting
## Accepts an optional file extension (e.g., "cs", "json", "yaml")
#gunstage() {
#  local -a selected_files
#  local repo_root file_extension="$1"
#  local unstage_all=false
#
#  # Check if the first argument is "all"
#  if [[ "$1" == "all" ]]; then
#    unstage_all=true
#    file_extension="$2"  # Shift the file extension if provided
#  fi
#
#  if $unstage_all; then
#    # Unstage all staged files
#    echo "Unstaging all staged files..."
#
#    # Determine the repository root
#    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
#    if [[ $? -ne 0 ]]; then
#      echo "Error: Not inside a Git repository."
#      return 1
#    fi
#
#    # Retrieve all staged files
#    if [[ -n "$file_extension" ]]; then
#      selected_files=($(git diff --name-only --cached | grep "\.${file_extension}$"))
#    else
#      selected_files=($(git diff --name-only --cached))
#    fi
#
#    # Check if there are any staged files
#    if (( ${#selected_files[@]} == 0 )); then
#      echo "No staged files to unstage."
#      return 0
#    fi
#
#    # Display the files being unstaged
#    echo "Unstaging the following file(s):"
#    for file in "${selected_files[@]}"; do
#      echo "- $file"
#    done
#    echo ""
#
#    # Unstage all files
#    git restore --staged -- "${selected_files[@]}"
#
#    # Alternative for older Git versions:
#    # git reset HEAD -- "${selected_files[@]}"
#
#    # Check if the git restore command was successful
#    if [[ $? -eq 0 ]]; then
#      echo "Successfully unstaged all files."
#    else
#      echo "Failed to unstage some or all files."
#    fi
#  else
#    # Interactive selection to unstage specific files
#    if [[ -n "$file_extension" ]]; then
#      selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to unstage" "$file_extension")}")
#    else
#      selected_files=("${(@f)$(git_select_files "staged" "Select file(s) to unstage")}")
#    fi
#
#    # If no files were selected, exit
#    if (( ${#selected_files[@]} == 0 )); then
#      echo "No files selected for unstaging."
#      return 0
#    fi
#
#    # Display the selected files
#    echo "Unstaging the following file(s):"
#    for file in "${selected_files[@]}"; do
#      echo "- $file"
#    done
#    echo ""
#
#    # Unstage the selected files
#    git restore --staged -- "${selected_files[@]}"
#
#    # Alternative for older Git versions:
#    # git reset HEAD -- "${selected_files[@]}"
#
#    # Check if the git restore command was successful
#    if [[ $? -eq 0 ]]; then
#      echo "Successfully unstaged the selected file(s)."
#    else
#      echo "Failed to unstage some or all selected files."
#    fi
#  fi
#}
