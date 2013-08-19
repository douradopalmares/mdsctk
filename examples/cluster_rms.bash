#!/bin/bash
##
## 
##                This source code is part of
## 
##                        M D S C T K
## 
##       Molecular Dynamics Spectral Clustering ToolKit
## 
##                        VERSION 1.1.1
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
## official version at <website>.
## 
## To help us fund MDSCTK development, we humbly ask that you cite
## the papers on the package - you can find them in the top README file.
## 
## For more info, check our website at http://github.com/douradopalmares/mdsctk/
## 
##

TOP=trp-cage.pdb
XTC=trp-cage.xtc

NTHREADS=2    ## Number of threads to use
KNN=100       ## Number of nearest neighbors to keep
NCLUSTERS=10  ## Number of clusters to extract
SCALING=12    ## (must be <= KNN) for calculating scaling factors...

echo "Computing RMS distances between all structure pairs..."
../knn_rms ${NTHREADS} ${KNN} ${TOP} ${XTC} ${XTC}

echo "Creating CSC format sparse matrix..."
../make_sysparse ${KNN}

echo "Performing autoscaled spectral decomposition..."
../auto_decomp_sparse ${NCLUSTERS} ${SCALING}

echo "Clustering eigenvectors..."
../kmeans.r

# Generate trajectory assignment file,
# 10 trajectories of 100 frames each.
Rscript \
    -e 'myout<-pipe("cat","w")' \
    -e 'write(sort(rep(seq(1,10),100)),myout,ncolumns=1)' \
    -e 'close(myout)' > assignment.dat

echo "Computing replicate-cluster assignment histogram..."
../clustering_histogram.r

echo "Plotting the histogram (fails if R package 'fields' is missing)..."
../plot_histogram.r

echo "Computing normalized mutual information..."
../clustering_nmi.r | tee nmi.dat
