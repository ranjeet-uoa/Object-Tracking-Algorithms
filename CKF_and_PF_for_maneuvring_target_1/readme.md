###  Cubature Kalman Filter and Particle Filters 
This directory contains the implementation of  Cubature Kalman Filter (CKF) and Particle Filters (PF). The purpose of these filters is to estimate the state of a system given a sequence of noisy observations of range and bearing sensors. Objects follow a constant turn-rate model.

### Directory Structure
The directory is organized into sub-folders, each containing the implementation of a specific filter:
- `PF/`: Contains the implementation of the Particle Filter.
- `CKF/`: Contains the implementation of the Cubature Kalman Filter.
Each sub-folder contains a `demo.m` file which can be run to demonstrate the filter.

### Running the Code
To run the individual filters, navigate to the corresponding sub-folder and run the `demo.m` file. For example, to run the Particle Filter, navigate to the `PF/` directory and run:
```matlab
demo
```

To compare the performance of the Cubature Kalman Filter and the Particle Filter, run the  `comparison_CKF_vs_PF.m`
```matlab
comparison_CKF_vs_PF
```
file in the root directory. This script runs each filter 250 times using Monte Carlo simulations and compares their performance in terms of Root Mean Square Error (RMSE) and processing time.

Please ensure that you have `MATLAB` installed and properly configured to run these scripts.
### Filter Initilization
This folder gives three options for initializing  the filters: 1. 'other' 2. 'SP' 3. 'TPD'. However, unfortunelty, only 'other' works for all filters implemented for the current problem.