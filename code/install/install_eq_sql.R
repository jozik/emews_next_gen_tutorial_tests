
# INSTALL EQ SQL R
# Installs EQ-SQL via the GitHub API
# When run under GitHub Actions,
#      install_github() requires a GitHub Personal Access Token
#      In this case, we set a secret for GITHUB_PAT and
#                    use it via ~/.Renviron.
#      https://snyk.io/blog/how-to-use-github-actions-environment-variables

# Install EQ.SQL!
remotes::install_github('emews/EQ-SQL/R/EQ.SQL')
