# Matlab Model (Mixed-Signal blockset)

Use model:

* After PLL analysis, run Matlab scripts to select component values based on input constraints (input reference frequency, loop Bandwidth multiplier, etc.), satisfying stability criteria, Loop bandwidth requirements, etc.
* Insert values into Matlab/Simulink model of Integer-N PLL (Filter order, R, C, Cx, Io, Kvco, etc.)

The goal of this Matlab / Simulink model is to verify that the PLL system will meet the following requirements:
* be stable
* will be able to lock to the correct frequency
* locking time will be within the required settling time and accuracy

