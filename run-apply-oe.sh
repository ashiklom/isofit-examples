#!/usr/bin/env bash

set -euxo pipefail

# Number of parallel cores
n_cores=4

# Name of conda environment you are using
CONDA_ENV_NAME="isofit-master"

# Change these paths and file names accordingly

# These are test datasets, which can be downloaded using these commands:
# curl -O https://avng.jpl.nasa.gov/pub/PBrodrick/isofit/test_data.zip
# unzip test_data.zip
rdn_file="$HOME/projects/sbg-uncertainty/data/isofit-test-data/small_chunk/ang20170323t202244_rdn_7000-7010"
loc_file="$HOME/projects/sbg-uncertainty/data/isofit-test-data/small_chunk/ang20170323t202244_loc_7000-7010"
obs_file="$HOME/projects/sbg-uncertainty/data/isofit-test-data/small_chunk/ang20170323t202244_obs_7000-7010"

# Path to the folder that contains "assets", "saved_model.pb", and "variables"
EMULATOR_PATH="$HOME/projects/sbg-uncertainty/sRTMnet_v100/sRTMnet_v100"
# Root of the ISOFIT source code directory. Contains "CITATION", "README.rst", "setup.py", etc.
ISOFIT_DIR="$HOME/projects/sbg-uncertainty/isofit-master"
# Path to 6S model directory. Note that this has to be compiled as well (run
# `make` inside this folder). The executable `sixsV2.1` should be in this folder.
SIXS_DIR="$HOME/projects/models/6sV-2.1/"

# Path to surface config
SURFACE_CONFIG_DIR="$HOME/projects/sbg-uncertainty/isofit-master/examples/image_cube/configs"

# Output directory. Will be created if it doesn't exist.
OUTPUT_DIR="./test-output"

# Create the surface file
conda run -n "$CONDA_ENV_NAME" python -u -c "from isofit.utils import surface_model; surface_model('$SURFACE_CONFIG_DIR/basic_surface.json')"

conda run -n "$CONDA_ENV_NAME" \
  ISOFIT_DIR="${ISOFIT_DIR}" \
  EMULATOR_DIR="${EMULATOR_PATH}" \
  SIXS_DIR="${SIXS_DIR}" \
  python -u "${ISOFIT_DIR}/isofit/utils/apply_oe.py" \
  "${rdn_file}" "${loc_file}" "${obs_file}" \
  "${OUTPUT_DIR}" \
  ang \
  --presolve=1 \
  --empirical_line=0 \
  --emulator_base="${EMULATOR_PATH}" \
  --n_cores ${n_cores} \
  --surface_path "$SURFACE_CONFIG_DIR/basic_surface.mat" \
  --copy_input_files 0