# Check if inside a valid git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
	: # Inside a git repo
else
	echo "not a git repo"
	exit 1
fi

# Check if repo is dirty
if [[ -n $(git status --porcelain) ]]; then
	echo "repo is dirty"
	exit 1
fi

# Determine default branch (main or master)
if git show-ref --verify --quiet refs/heads/main; then
	default_branch="main"
elif git show-ref --verify --quiet refs/heads/master; then
	default_branch="master"
else
	# Detect from origin HEAD if available
	remote_head=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
	default_branch="${remote_head#origin/}"
fi

if [[ -z "$default_branch" ]]; then
	echo "could not determine default branch (neither main nor master found)"
	exit 1
fi

# Checkout default branch
git checkout "$default_branch" || exit 1

pull_from_remote=upstream
# Check if upstream remote is defined
if git remote get-url upstream > /dev/null 2>&1; then
	# Pull upstream default branch
	git pull upstream "$default_branch" || exit 1
# Check if origin remote is defined
elif git remote get-url origin > /dev/null 2>&1; then
	# Pull origin default branch
	git pull origin "$default_branch" || exit 1
	pull_from_remote=origin
else
	echo "both upstream and origin remotes undefined"
	exit 1
fi

# Fetch all changes
git fetch --all --prune || exit 1

# Push default branch to origin (if pulled from upstream)
if [ "$pull_from_remote" = "upstream" ]; then
	git push origin "$default_branch" || exit 1
fi
