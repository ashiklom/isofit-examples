#!/usr/bin/env bash
#SBATCH --account s3673
#SBATCH --time 02:00:00

# Configuration for debugging. Specific options are:
#   -e -- Stop script on first error
#   -u -- Treat unset environment variables as errors
#   -x -- Print commands (and subcommands) as they are executed. Remove the `x` if the output is too verbose for you.
#   -o pipefail -- Stop script on errors inside of shell pipes.
set -euxo pipefail

# NOTE: We don't actually use this version of Python...but we do want to use
# the version of conda/mamba that is included inside of this module.
module load python/GEOSpyD/Min4.11.0_py3.9

################################################################################
# Paths and other variables in this section are likely to be changed by the user

# Output directory. Will be created if it doesn't exist.
OUTPUT_DIR="./test-output"

# Paths to radiance, location, and obs file, respectively. Refer to test
# datasets for the structure of these files.
rdn_file="/discover/nobackup/projects/SBG-DO/isofit-common/examples/test_data/small_chunk/ang20170323t202244_rdn_7000-7010"
loc_file="/discover/nobackup/projects/SBG-DO/isofit-common/examples/test_data/small_chunk/ang20170323t202244_loc_7000-7010"
obs_file="/discover/nobackup/projects/SBG-DO/isofit-common/examples/test_data/small_chunk/ang20170323t202244_obs_7000-7010"

# Number of parallel cores
n_cores=4

# ISOFIT arguments related to the empirical line correction.
EMPIRICAL_LINE_ARGS="--empirical_line=0"

# Comment out the version above and replace with the one below for larger
# images where an empirical line approach makes sense.
# EMPIRICAL_LINE_ARGS="--empirical_line=1 --segmentation_size 400"

# Isofit instrument type. Must be one of: ['ang', 'avcl', 'neon', 'prism', 'emit', 'hyp']
# See `isofit/utils/apply_oe.py` documentation for details.
INSTRUMENT_TYPE="ang"

################################################################################
# Paths in this section can usually stay constant (for a given system), though
# more experimental setups may require some changes.

# Path to conda environment you are using
CONDA_ENV_PATH="/discover/nobackup/projects/SBG-DO/conda-envs/isofit-master"

# Path to the folder that contains "assets", "saved_model.pb", and "variables"
EMULATOR_PATH="/discover/nobackup/projects/SBG-DO/isofit-common/sRTMnet_v100/sRTMnet_v100"
# Root of the ISOFIT source code directory. Contains "CITATION", "README.rst", "setup.py", etc.
ISOFIT_DIR="/discover/nobackup/projects/SBG-DO/isofit-common/isofit"
# Path to 6S model directory. Note that this has to be compiled as well (run
# `make` inside this folder). The executable `sixsV2.1` should be in this folder.
SIXS_DIR="/discover/nobackup/projects/SBG-DO/isofit-common/6sV-2.1/"

# Path to surface config.
SURFACE_CONFIG_DIR="$ISOFIT_DIR/examples/image_cube/configs"

# Create the surface file
conda run -p "$CONDA_ENV_PATH" python -u -c "from isofit.utils import surface_model; surface_model('$SURFACE_CONFIG_DIR/basic_surface.json')"

# NOTE: Below, because we are using `conda run`, we need to "re-forward"
# certain environment variables (ISOFIT_DIR, EMULATOR_DIR, SIXS_DIR) to the
# child Python process.
conda run -p "$CONDA_ENV_PATH" \
  ISOFIT_DIR="${ISOFIT_DIR}" \
  EMULATOR_DIR="${EMULATOR_PATH}" \
  SIXS_DIR="${SIXS_DIR}" \
  python -u "${ISOFIT_DIR}/isofit/utils/apply_oe.py" \
  "${rdn_file}" "${loc_file}" "${obs_file}" \
  "${OUTPUT_DIR}" \
  $INSTRUMENT_TYPE \
  --presolve=1 \
  $EMPIRICAL_LINE_ARGS \
  --emulator_base="${EMULATOR_PATH}" \
  --n_cores ${n_cores} \
  --surface_path "$SURFACE_CONFIG_DIR/basic_surface.mat" \
  --copy_input_files 0
