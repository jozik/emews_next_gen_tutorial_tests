
# INSTALL R PKGS

# Run this via install_emews.sh
# Installs all R packages needed for EMEWS workflows

print("INSTALL_R_PKGS: START")

# Installation settings:
r <- getOption("repos")
# Change this mirror as needed:
# r["CRAN"] <- "http://cran.cnr.berkeley.edu/"
# r["CRAN"] <- "http://cran.wustl.edu/"
# r["CRAN"] <- "https://mirror.las.iastate.edu/"
r["CRAN"] <- "https://cloud.r-project.org"
options(repos = r)
NCPUS = 1

PKGS <- list(
  "reticulate", "coro", "jsonlite", "purrr", "logger", "remotes"
)

for (pkg in PKGS) {
  print("")
  cat("INSTALL: ", pkg, "\n")
  # install.packages() does not return an error status
  install.packages(pkg, Ncpus=NCPUS, verbose=TRUE)
  print("")
  # Test that the pkg installed and is loadable
  cat("LOAD:    ", pkg, "\n")
  library(package=pkg, character.only=TRUE)
}

print("INSTALL_R_PKGS: DONE.")
