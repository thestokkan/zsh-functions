# ~/.zsh_functions/git_delete_branch.zsh

# Function to interactively select and delete Git branches using fzf
# Excludes 'main', 'master', and the current branch from the selection
# Prompts extra confirmation before force deleting branches
gdelbranch() {
  local pattern="$1"
  local branches selected_branches confirm

  # Determine the repository root
  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    echo "Error: Not inside a Git repository."
    return 1
  fi

  # Get current branch
  local current_branch
  current_branch=$(git branch --show-current)

  # Get list of local branches, optionally filtered by pattern, excluding current, main, master
  if [[ -n "$pattern" ]]; then
    branches=$(git branch --format='%(refname:short)' | grep -vE "^(main|master|${current_branch})$" | grep "$pattern")
  else
    branches=$(git branch --format='%(refname:short)' | grep -vE "^(main|master|${current_branch})$")
  fi

  # Check if there are any branches to delete
  if [[ -z "$branches" ]]; then
    echo "No branches available for deletion."
    return 0
  fi

  # Use fzf to select one or more branches
  selected_branches=($(echo "$branches" | fzf --multi --prompt="Select branch(es) to delete: " --height 40% --layout=reverse --info=inline))

  # If no branches were selected, exit
  if (( ${#selected_branches[@]} == 0 )); then
    echo "No branches selected for deletion."
    return 0
  fi

  # Display the selected branches
  echo "Selected branch(es) for deletion:"
  for branch in "${selected_branches[@]}"; do
    echo "- $branch"
  done
  echo ""

  # Confirm deletion
  read -p "Are you sure you want to delete the selected branch(es)? [y/N]: " confirm
  if [[ "$confirm" != [yY] ]]; then
    echo "Deletion aborted."
    return 0
  fi

  # Delete each selected branch
  for branch in "${selected_branches[@]}"; do
    git branch -d "$branch" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      # Prompt before force deleting
      read -p "Branch '$branch' has unmerged changes. Force delete? [y/N]: " force_confirm
      if [[ "$force_confirm" == [yY] ]]; then
        git branch -D "$branch"
        if [[ $? -eq 0 ]]; then
          echo "Force deleted branch '$branch'."
        else
          echo "Failed to delete branch '$branch'."
        fi
      else
        echo "Skipped force deleting branch '$branch'."
      fi
    else
      echo "Deleted branch '$branch'."
    fi
  done
}
