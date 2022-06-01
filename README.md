# PLL
Systematic design of PLL. From specs to GDS in one click. [WIP]

## Project scope

Programmatic synthesis of PLL system.

**Very ambitious! (Long Term)**

Specs --> Topology selection --> Matlab analysis --> Loop Filter order/Poles-Zeroes --> Component values (R, C, Cx, Io, Kvco) --> Model & Verify PLL closed loop stability --> Parameterized Netlist --> Layout (ALIGN) --> GDS


### What is done

* PLL analysis ([Integer-N](/Integer-N_PLL.md), [Fractional](/Fractional-N_PLL.md), [Sigma-Delta](/Sigma-Delta_PLL.md))
* Matlab model Integer-N PLL (around existing VCO)
* Stable & locks at **3.2GHz**
* Matlab scripts - automation of Poles & Zeroes analysis (Matlab Symbolic Math Toolbox), component values selection based on Loop BW constraints (R, C, Cx, Io) and Kvco. [scripts](/matlab)


### To be done / further work

* Feed component values into parameterized netlist, simulate transistor level with extracted VCO, see PLL startup, settling and locking.
* Layout of Loop Filter components and CP current sources, possibly using ALIGN automated layout framework (Fix local ALIGN install issues)
* Resimulate with PEX (if simulation resources / simulation time feasible)
* Generalize for other specs (top-down)


![image](https://user-images.githubusercontent.com/95447782/171378366-c615be31-f4d5-4b8e-9592-909750ed7b8f.png)



## PLL analysis

[PLL analysis](/PLL_analysis.md)

[Integer-N Phase Locked Loop](/Integer-N_PLL.md)

[Fractional-N Phase Locked Loop](/Fractional-N_PLL.md)

[Sigma-Delta modulation in fractional-N PLL](/Sigma-Delta_PLL.md)


 


## Matlab scripts

[Matlab model Integer-N PLL](/matlab/Matlab_Model_Integer-N_PLL.md) 

[Matlab scripts](/matlab)


## References

* Kishor Kunal, Meghna Madhusudan, Arvind K. Sharma, Wenbin Xu, Steven M. Burns, Ramesh Harjani, Jiang Hu, Desmond A. Kirkpatrick, and Sachin S. Sapatnekar. 2019. ALIGN: Open-Source Analog Layout Automation from the Ground Up. In Proceedings of the 56th Annual Design Automation Conference 2019 (DAC '19). Association for Computing Machinery, New York, NY, USA, Article 77, 1–4. DOI:https://doi.org/10.1145/3316781.3323471

* Hao Chen, Walker J. Turner, Sanquan Song, Keren Zhu, George F. Kokai, Brian Zimmer, C. Thomas Gray, Brucek Khailany, David Z. Pan, and Haoxing Ren. 2022. AutoCRAFT: Layout Automation for Custom Circuits in Advanced FinFET Technologies. In Proceedings of the 2022 International Symposium on Physical Design (ISPD '22). Association for Computing Machinery, New York, NY, USA, 175–183. DOI:https://doi.org/10.1145/3505170.3511044

* J. Liu et al., "From Specification to Silicon: Towards Analog/Mixed-Signal Design Automation using Surrogate NN Models with Transfer Learning," 2021 IEEE/ACM International Conference On Computer Aided Design (ICCAD), 2021, pp. 1-9, doi: DOI:https://doi.org/10.1109/ICCAD51958.2021.9643445.

* Huang, Guyue & Hu, Jingbo & He, Yifan & Liu, Jialong & Mingyuan, Ma & Shen, Zhaoyang & Wu, Juejian & Xu, Yuanfan & Zhang, Hengrui & Zhong, Kai & Ning, Xuefei & Ma, Yuzhe & Yang, H.Y. & Yu, Bei & Yang, Huazhong & Wang, Yu. (2021). Machine Learning for Electronic Design Automation: A Survey. ACM Transactions on Design Automation of Electronic Systems. 26. 1-46. 10.1145/3451179. 

* Settaluri, Keertana & Haj Ali, Ameer & Huang, Qijing & Hakhamaneshi, Kourosh & Nikolic, Borivoje. (2020). AutoCkt: Deep Reinforcement Learning of Analog Circuit Designs. 490-495. 10.23919/DATE48585.2020.9116200. 

* Wang, Hanrui & Yang, Jiacheng & Lee, Hae-Seung & Han, Song. (2018). Learning to Design Circuits. 
