#!/bin/bash

export PACKAGES=`python -c 'import site; print(site.getsitepackages()[0])'`

echo "####################################"
echo "#### QREFINE INSTALLER FOR CONDA ###"
echo "####################################"
echo ""
echo "python modules location: $PACKAGES"



### restraint libs
echo "Downloading restraints libraries"
cd $PACKAGES
mkdir chem_data
cd chem_data
svn --quiet --non-interactive --trust-server-cert co svn://svn.code.sf.net/p/geostd/code/trunk geostd
svn --quiet --non-interactive --trust-server-cert co https://github.com/rlabduke/mon_lib.git/trunk mon_lib
svn --quiet --non-interactive --trust-server-cert co https://github.com/rlabduke/reference_data.git/trunk/Top8000/Top8000_rotamer_pct_contour_grids rotarama_data
svn --quiet --non-interactive --trust-server-cert co  https://github.com/rlabduke/reference_data.git/trunk/Top8000/rama_z
rm -rf rotarama_data/.svn
svn --quiet --non-interactive --trust-server-cert --force co https://github.com/rlabduke/reference_data.git/trunk/Top8000/Top8000_ramachandran_pct_contour_grids rotarama_data
svn --quiet --non-interactive --trust-server-cert co https://github.com/rlabduke/reference_data.git/trunk/Top8000/Top8000_cablam_pct_contour_grids cablam_data
cd ..

# add missing modules
echo "Downloading qrefine"
mkdir $PACKAGES/modules
cd $PACKAGES/modules

#### QREFINE
cp -r $SRC_DIR $PACKAGES/modules/qrefine

#### PROBE
echo "Downloading probe"
svn --quiet --non-interactive --trust-server-cert co https://github.com/rlabduke/probe.git/trunk probe
cd probe
make
cp hybrid_36_c.c $PACKAGES/iotbx/pdb/hybrid_36_c.c
cd ..

### REDUCE
echo "Downloading reduce"
svn --quiet --non-interactive --trust-server-cert co https://github.com/rlabduke/reduce.git/trunk reduce
cd reduce
make
cd ..

### set up build dir and exes
echo "CCTBX-install packages"
mkdir $PACKAGES/build
cd $PACKAGES/build
mkdir -p probe/exe/
cp $PACKAGES/modules/probe/probe probe/exe/
mkdir -p reduce/exe
cp $PACKAGES/modules/reduce/reduce_src/reduce reduce/exe/

### run configure (still in ./build)
libtbx.configure probe qrefine reduce
mmtbx.rebuild_rotarama_cache
mmtbx.rebuild_cablam_cache

echo "run:"
echo "   source $PACKAGES/build/setpaths.sh"
