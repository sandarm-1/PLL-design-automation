# Matlab Model (Mixed-Signal blockset)

Target usage model:

* Do PLL analysis for a specific topology (Integer-N / Fractional-N / Sigma-Delta based fractional-N). Understand and model loop dynamics / transfer function on paper (loop filter, closed loop PLL system).
* Run Matlab scripts to select component values based on input constraints (input reference frequency, loop Bandwidth multiplier, etc.), satisfying stability criteria, Loop bandwidth requirements, etc. based on previous analysis.
* Insert values into Matlab/Simulink model of Integer-N PLL (Filter order, R, C, Cx, Io, Kvco, N divider ratio, etc.)




## Bottom-up design approach Versus Top-down
The end goal is to derive a **systematic, specs driven top-down approach** to designing a PLL system, in the most systematic and automated way possible, based  on certain input specifications.

However, prior to that stage we will go through a a **bottom-up** approach to build **a reference PLL model** from the ground up.

In this case, we will try to design an Integer-N PLL system around the existing [3GHz VCO](https://github.com/powergainer/vco). At this stage we will aim at putting together a reference PLL system that can output 3.2GHz from a 25MHz/50MHz input reference frequency, with well understood dynamics and behaviour, that we can **generalize, systematize and automate** later on.

The block diagram will look like this:



This type of **bottom-up design approach** is an effective way to build a good understanding of the circuit and the relationships that govern its behaviour. From here, a systematic top-down design approach can be derived, eventually deriving what could be considered a design recipe that would allow the effective design and optimization of the PLL system to a certain performance specification.


## 1st stage: Reference PLL design around existing 3GHz VCO (bottom-up stage)

In this first model, we are trying to design a PLL system around the existing [3GHz VCO](https://github.com/powergainer/vco).

The target is to put together a **reference PLL** system with well understood dynamics and behaviour, that we can generalize, systematize and automate later on.

The PLL should be able to output 3.2GHz from a 25MHz/50MHz input reference frequency with an Integer-N topology.

The goal of this Matlab / Simulink model is to verify that the PLL system will meet the following requirements:
* be stable
* will be able to lock to the correct frequency
* locking time will be within the required settling time and accuracy

Not much focus is put on noise / spurs performance although we recognize this is an important part of the design, but we are going for a basic Integer-N topology where spurs performance will not be ideal.

Input constraints are:
* VCO frequency curve (Fvco VS Vctrl) is known beforehand. This is given by the existing VCO design. Note: In other, more likely scenarios, the VCO would be designed to fit to the PLL specifications and not viceversa, but this is the scope at this particular stage.
* Kvco is therefore known and is an input constraint.
* N divider ratio 


