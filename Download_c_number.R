rm(list=ls())

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

FILE <- list.files(pattern = '.csv')

data <- read.csv(FILE)

link <- data$Link
link <- as.character(link)
output <- matrix(,ncol = 2, nrow =length(link))

require(RCurl)
require(XML)

for (a in 1:length(link)) {
  webpage <- getURL(link[a])
  webpage <- readLines(tc <- textConnection(webpage)); close(tc)
  pagetree <- htmlTreeParse(webpage, error=function(...){}, useInternalNodes = TRUE)
  
  x <- xpathSApply(pagetree, "//*/table", xmlValue)  
  # do some clean up with regular expressions
  x <- unlist(strsplit(x, "\n"))
  x <- gsub("\t","",x)
  x <- sub("^[[:space:]]*(.*?)[[:space:]]*$", "\\1", x, perl=TRUE)
  x <- x[!(x %in% c("", "|"))]
  
  output[a,1] <- x[3]
  output[a,2] <- x[4]
  output[a,2] <- strsplit(output[a,2], ";")[[1]]
}

data <- cbind(data,output)

write.csv(data,FILE)
