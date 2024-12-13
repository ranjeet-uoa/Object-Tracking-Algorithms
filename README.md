# Stream-1
This repository stores the relevant codes and documents related to ``DIP Activator Stream 1`` in two branches, the `MS1.1` and `MS1.2` under the `Main` branch.
## MS1.1
This milestone looks at the tracking of a single maneuvering target using two filters: `CKF` and `PF.`
There are two folders for these filter implementations:
- `CKF_and_PF_for_maneuvering_target/`: It has a fixed method for filter initialization
- `CKF_and_PF_or_maneuvering_target_1/`: It can do the filter initialization with three methods 
## MS1.2
This milestone looks at the tracking of multiple maneuvering targets with time-varying numbers, and by using unassigned measurements from a single active sensor with the help of two independent trackers: `GLMB_CKF` and `GLMB_PF.`

#### Directory Structure
There are two folders and two `.m' files inside the directory for the implementation of the trackers:
- `glmb_pf/`: It uses `GLMB_PF` method for tracking and has a `demo.m' file for independent demonstration.
- `glmb_ckf/`: It uses `GLMB_CKF` method for tracking and has a `demo.m' file for independent demonstration. 
- `_commom/': Both the above folders have this folder inside, and its path must be added to the Matlab editor while running demonstrations.
- `glmb_pf_n_ckf.m': This `.m` file runs a comparative demonstration for both the trackers. The paths to the two folders `glmb_pf` and `glmb_ckf` must be provided to the Matlab editor while running this file.

#### Running the demonstrations
To run the individual Milestone codes, navigate to the corresponding branch, the concerned sub-folder,  and run the `demo.m` file. For example, to run the GLMB_PF tracker for Milestone-1.2, navigate to the branch `MS1.1`, choose `glmb_pf/` directory and run:
```matlab
demo
```
file in the root directory.
