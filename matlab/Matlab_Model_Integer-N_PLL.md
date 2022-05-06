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

The target is to put together a **reference PLL** system with well understood dynamics and behaviour, that we can **generalize, systematize and automate** later on.

The PLL should be able to output 3.2GHz from a 25MHz/50MHz input reference frequency with an Integer-N topology.

The goal of this Matlab / Simulink model is to verify that the PLL system will meet the following requirements:
* be stable
* will be able to lock to the correct frequency
* locking time will be within the required settling time and accuracy

Note: Not much focus is put on noise / spurs performance (VCO noise profile is not characterized due to simulation tool constraints, i.e. ngspice doesn't support pnoise) although we recognize this is an important part of the design. We are going for a basic Integer-N topology where spurs performance will not be ideal and we will focus on functionality, stability, locking time.

Input constraints are:
* VCO frequency curve ([Fvco VS Vctrl](https://github.com/powergainer/vco)) is known beforehand. This is given by the existing VCO design. Note: In other, more likely scenarios, the VCO would be designed to fit to the PLL specifications and not viceversa, but this is the scope at this particular stage.
* [Kvco](https://github.com/powergainer/vco) is therefore known and is an input constraint.
* Input reference frequency
* N divider ratio (fout / fref). N is 128 for 25MHZ input reference to generate 3.2GHz output.


### Simulink model
Simulink model makes use of Integer-N PLL model built in with Mixed-Signal blockset.

This model is representative of the architecture that we are targetting around our existing VCO and is suitable for tuning system parameters such as Loop Filter, CP, etc.


Top level PLL testbench:
![image](https://user-images.githubusercontent.com/95447782/167127034-150b2c52-796e-463a-9ec8-7376fd91f764.png)

Integer-N PLL model:
![image](https://user-images.githubusercontent.com/95447782/167127150-d02aa65b-c42a-4028-a593-9a537b0430c3.png)


### VCO modelling
The VCO frequency vs voltage response and Kvco is modelled from the actual 3GHz VCO design.

The actual simulated [VCO Fvco VS Vctrl](https://user-images.githubusercontent.com/95447782/159693245-e04fc65c-b5fe-4d00-9a81-7a24189e1221.png) curves are translated to Simulink compatible format and fed into the model to have a realistic representation of the VCO Kvco which affects overall system stability.

![image](https://user-images.githubusercontent.com/95447782/159693245-e04fc65c-b5fe-4d00-9a81-7a24189e1221.png)


The following values model the VCO response at the x1 current multiplication mode. The voltage values are shifted down to be centered around 0V, where 0V represents an actual value of 0.9V Vctrl at circuit level. This is to comply with how the Loop Filter output is modelled in Matlab in the Mixed-Signal blockset.

![image](https://user-images.githubusercontent.com/95447782/167127805-54a1ec47-e35e-45c3-9df1-7f58e6adc23b.png)


### Loop filter parameters
The loop filter is fixed as a passive second order topology, as per our previous analysis. Loop filter component values (R, C, Cx) are calculated according to the [PLL analysis (Loop Filter, closed loop TF)](/PLL_analysis.md), trying to get close to a Loop Bandwidth constraint of 1/10 of fref, with help of the [Matlab scripts](/matlab) which can be used for further automation at later stages.

These values are fed into the Loop Filter model part of the PLL:

![image](https://user-images.githubusercontent.com/95447782/167128404-bf413d2e-0564-447a-9d5c-8ca04a6304ce.png)


### Charge Pump
Charge pump current is chosen as 20uA from stability analysis. A large Kvco value (something that would probably be better off fixed or reduced with the help of V-to-I circuit in the VCO, which is one of the proposed improvements) requires smaller charge pump current steps so that the output of the charge pump and loop filter doesn't make the loop swing in an unstable way.

![image](https://user-images.githubusercontent.com/95447782/167129063-25cc820a-c338-4e72-9b7f-f999920792d6.png)


### Prescaler / N feedback divider
The frequency divider in the feedback path is set to a division value of 128 to match with the requirement of generating 3.2GHz output from a 25MHz input reference frequency.

![image](https://user-images.githubusercontent.com/95447782/167129226-5aff9269-4c62-46b1-8744-0e5a37e8de5a.png)


### Closed loop / open loop dynamics
Based on previous values, the modeled closed loop / open loop dynamics is as follows. A phase margin of 47 degree is predicted in open loop analysis.

![image](https://user-images.githubusercontent.com/95447782/167129532-1ce21090-4b1b-48ed-8775-11bbedeb9c13.png)


### Transient behaviour / locking / settling time

