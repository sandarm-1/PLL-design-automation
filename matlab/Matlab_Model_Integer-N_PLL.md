# Matlab Model (Mixed-Signal blockset)

## Target usage model
The longer range, overarching goal is to derive a systematic, top-down design approach to designing a PLL from specifications in the most systematic and automated way possible.

The steps for the development of such model would be:

* Do PLL analysis for a specific topology (Integer-N / Fractional-N / Sigma-Delta based fractional-N). Understand and model loop dynamics / transfer function on paper (loop filter, closed loop PLL system).
* Setup and run Matlab scripts to select component values (such as R, C, Cx, Io...) based on whichever input constraints we have (input reference frequency, loop Bandwidth multiplier, Kvco, N divider ratio, etc.), satisfying stability criteria, Loop bandwidth requirements, etc. based on previous analysis.
* Feed values into Matlab/Simulink model of Integer-N PLL (Filter order, R, C, Cx, Io, Kvco, N divider ratio, etc.)
* Use said model to perform AMS verification of stability, locking frequency, locking time and other performance measures such as noise, spurs, output spectrum profile, etc.
* Once model parameters confirmed as valid, feed them into parameterized netlist generator (R, C, Cx, Io, etc.)
* Generate layout of sub-blocks and top level in most automatic way possible, possibly using ALIGN framework.
* Simulate and verify as close as possible to transistor level, with extracted netlist of as many blocks as feasible given simulation time constraints, at least key blocks requiring parasitic extraction such as VCO, etc. should be extracted.




## Bottom-up design approach Versus Top-down
The end goal is to derive a **systematic, specs driven top-down approach** to designing a PLL system, in the most systematic and automated way possible, based  on certain input specifications.

However, prior to that stage we will go through a a **bottom-up** approach to build **a reference PLL model** from the ground up.

The idea is that this type of **bottom-up design approach** is an effective way to build a good understanding of the circuit and the relationships that govern its behaviour. From here, a systematic top-down design approach can be derived, eventually deriving what could be considered a design recipe that would allow the effective design and optimization of the PLL system to a certain performance specification.

In this case, we will try to design an Integer-N PLL system around the existing [3GHz VCO](https://github.com/powergainer/vco). At this stage we will aim at putting together a reference PLL system that can output 3.2GHz from a 25MHz/50MHz input reference frequency, with well understood dynamics and behaviour, that we can **generalize, systematize and automate** later on.

The block diagram of the system will look like this:
![image](https://user-images.githubusercontent.com/95447782/167124691-7653abe8-ac64-4baf-9d02-32dbe72ef081.png)




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


