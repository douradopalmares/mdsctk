#!/usr/bin/env Rscript
##
## 
##                This source code is part of
## 
##                        M D S C T K
## 
##       Molecular Dynamics Spectral Clustering ToolKit
## 
##                        VERSION 1.2.0
## Written by Joshua L. Phillips.
## Copyright (c) 2013, Joshua L. Phillips.
## check out http://github.com/douradopalmares/mdsctk/ for more information.
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## If you want to redistribute modifications, please consider that
## derived work must not be called official MDSCTK. Details are found
## in the README & LICENSE files - if they are missing, get the
## official version at github.com/douradopalmares/mdsctk/.
## 
## To help us fund MDSCTK development, we humbly ask that you cite
## the papers on the package - you can find them in the top README file.
## 
## For more info, check our website at http://github.com/douradopalmares/mdsctk/
## 
##

if (Sys.getenv("MDSCTK_HOME")=="") {
    cat("\n")
    cat("Please set the MDSCTK_HOME environment variable\n")
    cat("before running this script.\n")
    cat("\n")
    q()
} else {
    program.name <- "kmeans.r"
    source(paste(Sys.getenv("MDSCTK_HOME"),"/mdsctk.r",sep=""))
}

cat("   Performs standard k-means clustering on the provided\n")
cat("   eigenvectors. The number of clusters requested (k), can\n")
cat("   be 2>=k<=nev where nev is the number of eigenvectors.\n")
cat("   The results are written to an assignment and index file.\n")
cat("\n")
cat("   Use -h or --help to see the complete list of options.\n")
cat("\n")

parser$add_argument("-k","--k",type="integer",
                    help="Number of clusters",metavar="integer")
parser$add_argument("-v","--evals",default="eigenvalues.dat",
                    help="File containing eigenvalues [default %(default)s]")
parser$add_argument("-e","--evecs",default="eigenvectors.dat",
                    help="File containing eigenvectors [default %(default)s]")
parser$add_argument("-o","--output",default="clusters.dat",
                    help="(Output) Cluster assignments file [default %(default)s]")
parser$add_argument("-n","--ndx",default="clusters.ndx",
                    help="(Output) Cluster assignment index file [default %(default)s]")

myargs <- parser$parse_args()

if (is.null(myargs$k)) {
    cat("ERROR: -k not supplied.\n")
    cat("\n")
    q()
}

cat("Running with the following options:\n")
cat(paste("k =      ",myargs$k,"\n"))
cat(paste("evals =  ",myargs$evals,"\n"))
cat(paste("evecs =  ",myargs$evecs,"\n"))
cat(paste("output = ",myargs$output,"\n"))
cat(paste("ndx =    ",myargs$ndx,"\n"))
cat("\n")

nclusters <- myargs$k
e.values <- as.double(scan(myargs$evals,quiet=TRUE))

if (nclusters > length(e.values) | nclusters < 2) {
    cat("\n")
    cat("ERROR:\n")
    cat(sprintf("Number of eigenvalues: %d\n",length(e.values)))
    cat(sprintf("Number of clusters requested: %d\n",nclusters))
    cat("The number of clusters requested must be >=2 and\n")
    cat("<= number of eigenvalues.\n")
    cat("\n")
    q()    
}

e.vectors <- matrix(scan(myargs$evecs,quiet=TRUE),ncol=length(e.values))
e.vectors <- as.matrix(e.vectors[,seq(1,nclusters)])
e.vectors <- apply(e.vectors,2,sqrt(rowSums(e.vectors^2)),FUN="/")
temp <- gc()

set.seed(0) # Change for different results...
clusters <- kmeans(e.vectors,
                   nclusters,
                   iter.max=30,
                   nstart=10)$cluster

cat("Cluster assignment percentage:\n")
for (x in seq(1,nclusters)) {
    cat(sprintf("%5d: %-10g\n",x,100*length(which(clusters==x))/length(clusters)))
}
cat("\n")

myout <- file(myargs$output,"w")
write(clusters,myout,ncolumns=1)
close(myout)

myout <- file(myargs$ndx,"w")
for (n in seq(1,ncol(e.vectors))) {
    writeLines(sprintf("[cluster_%d]",n),con=myout)
    write(which(clusters==n),myout,ncolumns=20)
    writeLines("",con=myout)
}
close(myout)

q(save="no")
