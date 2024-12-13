# Stream-1
This repository stores the relevant codes and documents related to ``DIP Activator Stream 1``
### MS1.2
This milestone looks at the tracking of multiple maneuvering targets with time-varying numbers and by using unassigned measurements from a single active sensor with the help of two independent trackers: `GLMB_CKF` and `GLMB_PF.`

#### Directory Structure
There are two folders and two `.m' files inside the main directory `MS1.2` for these tracker implementations:
- `glmb_pf/`: It uses `GLMB_PF` method for tracking and has a `demo.m' file for independent demonstration.
- `glmb_ckf/`: It uses `GLMB_CKF` method for tracking and has a `demo.m' file for independent demonstration. 
- `_commom/': Both the above folders have this folder inside it, and its path must be added to the Matlab editor while running demonstrations.
- `glmb_pf_n_ckf.m' : This `.m` file runs a comparative demonstration for both the trackers. The paths to the two folders `glmb_pf` and `glmb_ckf` must be provided to the Matlab editor while running this file.

#### Running the demonstrations
To run the individual trackers, navigate to the corresponding sub-folder and run the `demo.m` file. For example, to run the GLMB_PF, navigate to the `glmb_pf/` directory and run:
```matlab
demo
```

To compare the performance of the GLMB_PF and the GLMB_CKF, run the  `glmb_pf_n_ckf.m`
```matlab
glmb_pf_n_ckf
```
file in the root directory. This script runs each tracker once and compares their performance in terms of OSPA, OSPA2, and estimated cardinality.
