
#' https://gist.github.com/noamross/a549ee50e8a4fd68b8b1
#' Source the R code from an knitr file, optionally skipping plots
#'
#' @param file the knitr file to source
#' @param skip_plots whether to make plots. If TRUE (default) sets a null graphics device
#'
#' @return This function is called for its side effects
#' @export
source_rmd <- function(file, skip_plots = TRUE) {
	temp = tempfile(fileext=".R")
	knitr::purl(file, output=temp)
	
	if(skip_plots) {
		old_dev = getOption('device')
		options(device = function(...) {
			.Call("R_GD_nullDevice", PACKAGE = "grDevices")
		})
	}
	source(temp)
	if(skip_plots) {
		options(device = old_dev)
	}
}