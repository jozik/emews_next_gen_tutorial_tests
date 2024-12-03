
# INSTALL EQ SQL R
# Installs EQ-SQL via the GitHub API
# When run under GitHub Actions,
#      install_github() requires a GitHub Personal Access Token
#      In this case, we set a secret for GITHUB_PAT and
#                    use it via ~/.Renviron.
#      https://snyk.io/blog/how-to-use-github-actions-environment-variables

## if (Sys.getenv("GITHUB_PAT") != "") {
##   print("GITHUB_PAT detected.  Installing gitcreds...")

##   r <- getOption("repos")
##   # Change this mirror as needed:
##   # r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
##   # r["CRAN"] <- "http://cran.wustl.edu/"
##   # r["CRAN"] <- "https://mirror.las.iastate.edu/"
##   r["CRAN"] <- "https://cloud.r-project.org"
##   options(repos = r)

##   # Install gitcreds!
##   install.packages("gitcreds", verbose=TRUE)

##   print("")
##   print("LOAD:    gitcreds")
##   library(gitcreds)
## }

# Install EQ.SQL!
remotes::install_github('emews/EQ-SQL/R/EQ.SQL')
