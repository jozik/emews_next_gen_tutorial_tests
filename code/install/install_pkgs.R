
# INSTALL R PKGS

# Run this via install_emews.sh
# Installs all R packages needed for EMEWS workflows
# Loads them immediately after installation as a test,
#       because R does not report errors when installations fail.

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

# As of 2024-05-29, need to install jsonlite before reticulate
PKGS <- list(
  "coro", "jsonlite", "purrr", "logger", "remotes"
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

# As of 2024-05-29, need to install reticulate 1.4
# Cf. https://github.com/satijalab/seurat/issues/5650
pkg = "reticulate"
cat("INSTALL: ", pkg, "\n")
pkg_file = sprintf("%s/%s/%s/%s%s",
                   r["CRAN"], "src/contrib/Archive",
                   pkg, pkg, "_1.4.tar.gz")
cat("FILE:    ", pkg_file, "\n")
install.packages(pkg_file, repos=NULL, type="source")
cat("LOAD:    ", pkg, "\n")
library(package=pkg, character.only=TRUE)

print("INSTALL_R_PKGS: DONE.")
