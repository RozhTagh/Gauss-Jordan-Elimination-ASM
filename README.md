# Gauss-Jordan Elimination in Assembly

This repository contains two implementations of the Gauss-Jordan elimination algorithm in different assembly languages:

1. **IBM s390x Assembly**
2. **x86 Assembly (including SSE2 SIMD)**

## Overview

Gauss-Jordan elimination is a method used in linear algebra to solve systems of linear equations. It is an extension of Gaussian elimination and can be used to find the inverse of a matrix as well as to solve systems of linear equations.

## Repository Structure

- `IBM/driver.c`: C driver program for the IBM s390x assembly code.
- `IBM/run.sh`: Script to compile and run the IBM s390x assembly code.
- `IBM/IBM-Elimination.asm`: Implementation of Gauss-Jordan elimination in IBM s390x assembly language.
- `x86/driver.c`: C driver program for the x86 assembly code.
- `x86/run.sh`: Script to compile and run the x86 assembly code.
- `x86/x86-Elimination.asm`: Implementation of Gauss-Jordan elimination in x86 assembly language.
- `x86/x86-Elimination-SIMD.asm`: Implementation of Gauss-Jordan elimination using x86 SSE2 SIMD instructions.

## Prerequisites

To assemble and run these codes, you will need an appropriate assembler and emulator or hardware that supports the respective architecture.

### IBM s390x Assembly

- Assembler: `as` (GNU assembler)
- Emulator: `hercules` (or an IBM mainframe)

### x86 Assembly

- Assembler: `nasm`
- Emulator: `qemu` or a native x86 environment

## Usage

### IBM s390x Assembly

```
cd IBM
./run.sh IBM-Elimination
```

### x86 Assembly

For the standard x86 implementation:
```
cd x86
./run.sh x86-Elimination
```

For the SSE2 SIMD implementation:
```
cd x86
./run.sh x86-Elimination-SIMD
```
