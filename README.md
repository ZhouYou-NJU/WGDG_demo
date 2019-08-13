# WFG_demo
Description: Lensless imaging reconstruction code using Wirtinger flow optimization <br>

Title: Matlab code for "Noise-robust lensless imaging based on Wirtinger flow optimization" <br>
Author: You Zhou (zhouyou@nju.edu.cn), Xia Hua, Zibang Zhang and Xuemei Hu, etc. <br>
Version: 1.0 <br>
Copyright: 2019, You Zhou, Xia Hua, Zibang Zhang, Xuemei Hu, Jingang Zhong, Guoan Zheng, Xun Cao*. <br>

# Matlab code for "Noise-robust lensless imaging based on Wirtinger flow optimization"
This package contains an implementation of the Phase-space deconvolution algorithm described in 
the paper: You Zhou, Xia Hua, Zibang Zhang and Xuemei Hu, etc, "Noise-robust lensless imaging 
based on Wirtinger flow optimization". <br>

Please cite our paper if using the code in an academic publication. <br>

For algorithmic details, please refer to our paper. <br>

---
## How to use
The code is tested in MATLAB 2014b and 2018a (64bit) under the MS Windows 10 64bit version with Intel Core i7-8700 CPU @ 3.20GHz and 32GB RAM. <br>

1. Unpack the package.
2. Include code and subdirectory in your Matlab path.
3. Run "main.m" to test the demo included in this package.

Besides, <br>
1. The folder **GenerateIlluminationPattern** includes codes to generate illumination Patterns.
2. The folder **GenerateRawImageSet** includes codes to generate Raw Image Set in differet situations.
3. **getRec_GS()** is the GS reconstruction function, and **getRec_WFG()** is the proposed WFG reconstruction function.
4. **getRoundMatrixMask()** generates the pinhole mask matrix in use, and **prop()** realizes the free-space propagation of light field.

## Parameters setting

## Important note
If you have any questions regarding this code, please contact You Zhou (zhouyou@nju.edu.cn).

The GS algorithm of lensless imgaing is based on the following references: <br>
1. A. M. Maiden and J. M. Rodenburg, “An improved ptychographical phase retrieval algorithm for diffractive imaging,”
Ultramicroscopy 109, 1256–1262 (2009).
2. Z. Zhang, Y. Zhou, S. Jiang, K. Guo, K. Hoshino, J. Zhong, J. Suo, Q. Dai, and G. Zheng, “Invited article:
Mask-modulated lensless imaging with multi-angle illuminations,” APL Photonics 3, 060803 (2018).
