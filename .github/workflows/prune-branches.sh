#!/bin/bash

# Set the repository name and GitHub API token
REPO_NAME="cleanup-demo"
GITHUB_TOKEN="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"

# Set the number of days to keep branches
DAYS_TO_KEEP=30

# Get the list of branches in the repository
branches=$(curl -s -X GET \
  https://api.github.com/repos/${REPO_NAME}/branches \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "Content-Type: application/json" | jq -r '.[] | .name')

# Loop through each branch and get its last updated date
for branch in $branches; do
  updated_at=$(curl -s -X GET \
    https://api.github.com/repos/${REPO_NAME}/commits/${branch} \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" | jq -r '.commit.author.date')

  # Convert the updated date to a Unix timestamp
  updated_at_timestamp=$(date -d "$updated_at" +%s)

  # Calculate the age of the branch in days
  age_in_days=$(( ($(date +%s) - updated_at_timestamp) / 86400 ))

  # If the branch is older than 30 days, delete it
  if [ $age_in_days -gt $DAYS_TO_KEEP ]; then
    echo "Deleting branch ${branch} (last updated ${updated_at})"
    curl -s -X DELETE \
      https://api.github.com/repos/${REPO_NAME}/git/refs/heads/${branch} \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Content-Type: application/json"
  fi
done
