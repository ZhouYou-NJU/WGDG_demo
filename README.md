# WGDG_demo
*Description: Lensless imaging reconstruction code using Wirtinger gradient descent optimization. <br>*

Title: Matlab code for "Wirtinger gradient descent optimization for reducing Gaussian noise in lensless microscopy" <br>
Author: You Zhou (zhouyou@nju.edu.cn), Xia Hua, Zibang Zhang and Xuemei Hu, etc. <br>
Version: 1.0 <br>
Copyright: 2019, You Zhou, Xia Hua, Zibang Zhang, Xuemei Hu, Krishna Dixit, Jingang Zhong, Guoan Zheng, Xun Cao*. <br>

# Matlab code for "Wirtinger gradient descent optimization for reducing Gaussian noise in lensless microscopy"
This package contains an implementation of Wirtinger gradient descent optimization based lensless imaging algorithm 
described in the paper: You Zhou, Xia Hua, Zibang Zhang and Xuemei Hu, etc., "Wirtinger gradient descent optimization for reducing Gaussian noise in lensless microscopy". <br>

Please cite our paper if using the code in an academic publication. <br>

For algorithmic details, please refer to our paper. <br>

## How to use
The code is tested in MATLAB 2014b and 2018a (64bit) under the MS Windows 10 64bit version with
Intel Core i7-8700 CPU @ 3.20GHz and 32GB RAM. <br>

1. Unpack the package.
2. Include code and subdirectory in your Matlab path.
3. Run "main.m" to test the demo included in this package.

## Some illustrations
1. The folder **GenerateIlluminationPattern** includes codes to generate illumination patterns.
2. The folder **GenerateRawImageSet** includes codes to generate raw image set in differet situations.
3. **getRec_GS()** is the GS reconstruction function, and **getRec_WGDG()** is the proposed WGDG 
reconstruction function.
4. **getRoundMatrixMask()** generates the pinhole mask matrix in use, and **prop()** realizes the 
free-space propagation of light field.
5. The derivative process of our algorithm uses both the vector or matrix forms. But the final updating equations
of WF algorithm are all represented in matrices for more efficient calculation and easier code realization 
(like by MATLAB).

## Parameters setting
We realize both GS and WGDG algorithms of lensless imaging with mask updating in the demo. The GS 
algorithm here is based on the references [1][2]. <br>
1. The GS method will reduce the contrast of recovered image with the existance of noise, so a contrast 
enhancement process (set ***CEflag = 1***) is always needed to show the result. The proposed WGDG method 
does not have this problem. However, for fair performance comparison, the images shown in the paper all 
have adjusted their contrast using the 'Adjust the brightness and contrast' function and 'Auto' button 
of ImageJ. 
2. For WGDG reconstruction, the ***Delta*** parameters (gradient descent step sizes) are improtant, which 
can be set according to the equations in the paper, but always need careful adjustment. In fact, these 
parameters can be set to some constant values empirically. For example, we can simply set the ***Delta*** 
parameters of **object**, **pinhole mask**, and **noise matrix** to 0.5, 0.008, and 0.002 respectively. 

## Important notes
If you have any questions regarding this code, please contact You Zhou (zhouyou@nju.edu.cn).

References of GS algorithm for lensless imaging: <br>
1. A. M. Maiden and J. M. Rodenburg, “An improved ptychographical phase retrieval algorithm for diffractive imaging,”
Ultramicroscopy 109, 1256–1262 (2009).
2. Z. Zhang, Y. Zhou, S. Jiang, K. Guo, K. Hoshino, J. Zhong, J. Suo, Q. Dai, and G. Zheng, “Invited article:
Mask-modulated lensless imaging with multi-angle illuminations,” APL Photonics 3, 060803 (2018).
