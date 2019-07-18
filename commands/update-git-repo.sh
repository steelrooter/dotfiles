# Check if inside a valid git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
	: # Inside a git repo
else
	echo "not a git repo";
	exit 1
fi

# Check if repo is dirty
if [[ -n $(git status --porcelain) ]]; then
	echo "repo is dirty";
	exit 1
fi

# Checkout master
git checkout master || exit 1

# Pull upstream master
git pull upstream master || exit 1

# Fetch all changes
git fetch --all --prune || exit 1

# Push master to origin
git push origin master || exit 1
