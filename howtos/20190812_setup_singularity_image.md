HowTo Setup A New Singularity Image
================

## Summary

`tl;dr`. The process of building a new singularity container and pulling
it from the singularity hub (SHUB) repository onto a new machine is
summarized in this section.

### Building a New Container

Based on a `history | grep singularity` on `1-htz`, the following result
is obtained.

    SIMGFN=`date +"%Y%m%d%H%M%S"`_quagzws_ubuntu1804lts.img
     1149  sudo singularity image.create --size 1024 ${SIMGFN}
     1155  sudo singularity build ${SIMGFN} ../../def/ubuntu1804lts/quagzws_ubuntu1804lts.def &> `date +"%Y%m%d%H%M%S"`_quagzws201904_ubuntu1804lts_build.log &

The above `grep`-result shows the required two steps to create a new
singularity image.

1.  Create an image file
2.  Build the singularity container inside of the image file using the
    specified definition file.

**Hint**: Because step 2 can take a while, it is worth-while to run it
inside of a screen.

### Pulling A Container From SHUB

## Background
