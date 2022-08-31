# Example scripts for running ISOFIT

- `get-test-data.sh` -- Downloads some example datasets from JPL server and unzips them into the `test_data` folder.
- `run-apply-oe.sh` -- Example bash script for running Isofit `apply_oe` workflow (the "default" way to perform atmospheric correction using Isofit). Includes `SBATCH` directives for NCCS DISCOVER (you must be a member of project s3673, "SBG DO"). Also serves as an effective template script for running the workflow on other images.

## Running on NCCS DISCOVER

It is best practice to run Isofit workflows as batch jobs.
Because `run-apply-oe.sh` already has all the `SBATCH` flags you need, you can simply do the following to submit a job.

  ``` bash
  sbatch run-apply-oe.sh
  ```

If you need to do some interactive runs (e.g., for testing or debugging), best practice is to do so on an interactive compute node.
You can request a compute node for, e.g., 48 minutes, with a command like the following:

  ``` bash
  srun -A s3673 -t 48 --pty bash 
  ```

This command will request the compute resources and, when ready, will automatically log you into the compute node when resources are available.

From there, you can just run `bash run-apply-oe.sh`.

For more fine-grained debugging, start by loading the Python 3.9 module (which includes `conda` and `mamba` pre-installed).

  ``` bash
  module load python/GEOSpyD/Min4.11.0_py3.9
  ```

Next, activate the pre-installed `isofit-master` conda environment.

  ``` bash
  mamba activate /discover/nobackup/projects/SBG-DO/conda-envs/isofit-master 
  ```

NOTE: If this command fails with an error about your shell not being configured, run `mamba init` to configure your shell.
You should only have to do this step once per system.

Finally, use this environment to run whatever code you need to for testing.
