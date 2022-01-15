# Mips Processor

<p align="center">
  <img src="https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/MIPS_Layout.png">
</p>

### Summary

This is the final project in the course CPR E 381 (Computer Organization and Assembly Level Programming). In this project we developed and programmed MIPS processors utilizing both single-cycle designs and pipelined designs. For the class, we had designed all components in VHDL, after the class ended, I had went back and re-wrote the final pipelined processor in Verilog, then synthesized it using virtuoso.

## Single Cycle Design

### Single Cycle Schematic

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Single-Cycle-Schematic.png)

### Explanation

The single cycle design is the simplest design covered in class. In a single cycle processor, when an instruction is executed, the processor will execute all parts of that instruction within a single cycle. The main advantage of a single cycle design would be simplicity, and low instruction latency.

### Critical Path

The critical path is the path wich takes the longest to execute. In order for us to be able execute all instructions, we need to tune our clock speed to the worst case instruction. In the image below, we can see our worse case timing is gonna involve all write-back commands, and in order to improve speed further, we should try to improve any of the components found in that red-path.

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Single_Cycle_Critical_path.png)

## Software Scheduled Pipelined Cycle Design

### Software Scheduled Schematic

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Software Pipelined Processor.png)

### Explanation

In this processor design, we implement a standard 5-stage pipeline, but implement all control and data hazard avoidance within the software itself. In our specific case, we did this by inserting NOPS into the assembly code, but in practice this could be done by a compiler. 

### Critical Path

In the schematic below, we can see that the critical path goes through the ALU and back to the program counter. There is a lot of room for improvement in this design in terms of speed. For example, this design uses a Ripple-carry adder instead of a Carry-lookahead adder, and the logic that checks for a value of zero, has 32 cascaded 'or' gates instead of 1 large gate.

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Software-Pipeline-Processor-Critical Path.png)

## Hardware Scheduled Pipelined Cycle Design

### Hardware Scheduled Schematic

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Pipelined-Processor-Forwarding.png)

### Explanation

In this processor design, we had altered the previous by adding in a hazard detect and data forwarding unit. The modules work by passing data to the Instruction fetch stage when needed, and stalling the processor when it detects that it cannot forward data. The hazard detect unit is also responsible for flushing the pipeline in the event of a mispredicted branch operation. The benefits of having a hardware scheduling is that it prevents processor stalls in some cases (Helps to keep CPI close to 1), no NOPS are added by the compiler, affectively reducing the size of the code,

### Critical Path

A big issue with this implementation of the hardware scheduling, is that it dramatically slows down the processor. The hazard detect unit was significantly slower than the single mux in the path before reducing the clock speed by nearly 28%!

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/Critical-Path-Pipelined-Processor-Forwarding.png)

## Hardware Scheduled Pipelined Cycle Design (Verilog)

### Explanation

The purpose of re-writing the final processor design in verilog was to make synthesise easier. Outside of just being more comfortable with Verilog and it being easier to synthesize, there was not alot of benefit to making a verilog version. It mostly served as practice and allowed me to go over and apply some smaller optimizations to the existing processor.

### Synthesis process

Synthesis was performed using the OSU_stdcells_ami05 library. First we took the raw Verilog files and ran them through Genus, which is a tool that maps and optimizes the verilog code using the standard cells in the ami05 library.

Once Genus finished, we took the optimized file, and ran it through Innovus, wich allowed configuring of different aspects of the design like floorplan, IO placement, etc. The final results was the image below. One important thing to note however, is that in this processor design, instruction and data memory are integrated in the chip. As a result, the resultant image I put below, only the memory modules are visible becuase they dwarf the size of all other components.

![](https://github.com/JMcGhee-CPE/JMcGhee-CPE.github.io/blob/main/assets/img/MIPS_Layout.png)


