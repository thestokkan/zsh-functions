# ~/.zsh_functions/git_select_files.zsh

# Helper function to select files based on criteria and optional file extension
git_select_files() {
  local criteria="$1"
  local prompt="$2"
  local file_extension="$3"
  local repo_root selected_files files all_option="ALL"

  # Determine the repository root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  # If not inside repo root, save current directory and navigate to the repository root to ensure consistent path handling
  # Clear the directory stack first
  dirs -c
  if [[ "$PWD" != "$repo_root" ]]; then
    pushd "$repo_root" > /dev/null || return 1
  fi

  if [[ "$criteria" == "changed" ]]; then
    # List all changed files (both staged and unstaged)
    # This includes modified, added, deleted, renamed, and copied files
    if [[ -n "$file_extension" ]]; then
      # Filter files by the provided extension
      files=($(git status --short | awk '{print $2}' | grep "\.${file_extension}$"))
    else
      files=($(git status --short | awk '{print $2}'))
    fi
  elif [[ "$criteria" == "staged" ]]; then
    # List all staged files
    if [[ -n "$file_extension" ]]; then
      # Filter staged files by the provided extension
      files=($(git diff --name-only --cached | grep "\.${file_extension}$"))
    else
      files=($(git diff --name-only --cached))
    fi
  elif [[ "$criteria" == "unstaged" ]]; then
    # List all unstaged changed files
    if [[ -n "$file_extension" ]]; then
      # Filter unstaged and untracked files by the provided extension
      changed=($(git diff --name-only | grep "\.${file_extension}$"))
      untracked=($(git ls-files --others --exclude-standard | grep "\.${file_extension}$"))
    else
      changed=($(git diff --name-only))
      untracked=($(git ls-files --others --exclude-standard))
    fi
    # Combine both changed and untracked files
    files=("${changed[@]}" "${untracked[@]}")
  else
    echo "Error: Unknown criteria '$criteria'. Use 'changed', 'staged', or 'unstaged'."
    if [[ $(dirs -v | wc -l) -gt 1 ]]; then
      popd > /dev/null || return 1
    fi
    return 1
  fi

  # Check if there are any files
  if (( ${#files[@]} == 0 )); then
    echo "No files available for the criteria '$criteria'${file_extension:+ with extension '.$file_extension'}."
    if [[ $(dirs -v | wc -l) -gt 1 ]]; then
      popd > /dev/null || return 1
    fi
    return 0
  fi

  # Prepend the "ALL" option to the files list
  # This allows users to select "ALL" to operate on all files without individual selection
  local fzf_input
  fzf_input=("$all_option" "${files[@]}")

  # Use fzf to select multiple files
  selected_files=($(printf '%s\n' "${fzf_input[@]}" | fzf --multi --prompt="$prompt: " --height 40% --layout=reverse --info=inline))

  # Check if "ALL" was selected
  for selected in "${selected_files[@]}"; do
    if [[ "$selected" == "$all_option" ]]; then
      # If "ALL" is selected, return all files
      printf '%s\n' "${files[@]}"
      return 0
    fi
  done

  # If "ALL" was not selected, return the selected files
  if (( ${#selected_files[@]} == 0 )); then
    echo ""
    return 0
  fi

  # Output selected files, each on a new line
  printf '%s\n' "${selected_files[@]}"

  if [[ $(dirs -v | wc -l) -gt 1 ]]; then
      popd > /dev/null || return 1
  fi
}
