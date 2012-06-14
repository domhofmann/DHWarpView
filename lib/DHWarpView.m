/*
Copyright (c) 2012, Dominik Hofmann
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <QuartzCore/QuartzCore.h>
#import "DHWarpView.h"

typedef struct
{
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    CGPoint p4;
} DHWVQuad;

@implementation DHWarpView
@synthesize baseSize;
@synthesize topLeft, topRight, bottomRight, bottomLeft;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.baseSize = frame.size;
    }
    return self;
}

- (void)getGaussianElimination:(CGFloat *)input count:(int)n {
    float * A = input;
	int i = 0;
	int j = 0;
	int m = n-1;
	while (i < m && j < n){
        // Find pivot in column j, starting in row i:
        int maxi = i;
        for(int k = i+1; k<m; k++){
            if(fabs(A[k*n+j]) > fabs(A[maxi*n+j])){
                maxi = k;
            }
        }
        if (A[maxi*n+j] != 0){
            //swap rows i and maxi, but do not change the value of i
            if(i!=maxi)
                for(int k=0;k<n;k++){
                    float aux = A[i*n+k];
                    A[i*n+k]=A[maxi*n+k];
                    A[maxi*n+k]=aux;
                }
            //Now A[i,j] will contain the old value of A[maxi,j].
            //divide each entry in row i by A[i,j]
            float A_ij=A[i*n+j];
            for(int k=0;k<n;k++){
                A[i*n+k]/=A_ij;
            }
            //Now A[i,j] will have the value 1.
            for(int u = i+1; u< m; u++){
                //subtract A[u,j] * row i from row u
                float A_uj = A[u*n+j];
                for(int k=0;k<n;k++){
                    A[u*n+k]-=A_uj*A[i*n+k];
                }
                //Now A[u,j] will be 0, since A[u,j] - A[i,j] * A[u,j] = A[u,j] - 1 * A[u,j] = 0.
            }
            
            i++;
        }
        j++;
	}
    
	//back substitution
	for(int i=m-2;i>=0;i--){
		for(int j=i+1;j<n-1;j++){
			A[i*n+m]-=A[i*n+j]*A[j*n+m];
			//A[i*n+j]=0;
		}
	}
}

- (CATransform3D)homographyMatrixFromSource:(DHWVQuad)src destination:(DHWVQuad)dst {
    float P[8][9] = {
        {-src.p1.x, -src.p1.y, -1,   0,   0,  0, src.p1.x*dst.p1.x, src.p1.y*dst.p1.x, -dst.p1.x }, // h11
        {  0,   0,  0, -src.p1.x, -src.p1.y, -1, src.p1.x*dst.p1.y, src.p1.y*dst.p1.y, -dst.p1.y }, // h12
        
        {-src.p2.x, -src.p2.y, -1,   0,   0,  0, src.p2.x*dst.p2.x, src.p2.y*dst.p2.x, -dst.p2.x }, // h13
        {  0,   0,  0, -src.p2.x, -src.p2.y, -1, src.p2.x*dst.p2.y, src.p2.y*dst.p2.y, -dst.p2.y }, // h21
        
        {-src.p3.x, -src.p3.y, -1,   0,   0,  0, src.p3.x*dst.p3.x, src.p3.y*dst.p3.x, -dst.p3.x }, // h22
        {  0,   0,  0, -src.p3.x, -src.p3.y, -1, src.p3.x*dst.p3.y, src.p3.y*dst.p3.y, -dst.p3.y }, // h23
        
        {-src.p4.x, -src.p4.y, -1,   0,   0,  0, src.p4.x*dst.p4.x, src.p4.y*dst.p4.x, -dst.p4.x }, // h31
        {  0,   0,  0, -src.p4.x, -src.p4.y, -1, src.p4.x*dst.p4.y, src.p4.y*dst.p4.y, -dst.p4.y }, // h32
    };
    
    [self getGaussianElimination:&P[0][0] count:9];
    
    CATransform3D matrix = CATransform3DIdentity;
    
    matrix.m11 = P[0][8];
    matrix.m21 = P[1][8];
    matrix.m31 = 0;
    matrix.m41 = P[2][8];
    
    matrix.m12 = P[3][8];
    matrix.m22 = P[4][8];
    matrix.m32 = 0;
    matrix.m42 = P[5][8];
    
    matrix.m13 = 0;
    matrix.m23 = 0;
    matrix.m33 = 1;
    matrix.m43 = 0;
    
    matrix.m14 = P[6][8];
    matrix.m24 = P[7][8];
    matrix.m34 = 0;
    matrix.m44 = 1;
    
    return matrix;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self warp];
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
    [super setNeedsDisplayInRect:rect];
    [self warp];
}

- (void)warp {
    
    DHWVQuad src;
    src.p1 = CGPointMake(0, 0);
    src.p2 = CGPointMake(baseSize.width, 0);
    src.p3 = CGPointMake(baseSize.width, baseSize.height);
    src.p4 = CGPointMake(0, baseSize.height);
    
    DHWVQuad dst;
    dst.p1 = topLeft;
    dst.p2 = topRight;
    dst.p3 = bottomRight;
    dst.p4 = bottomLeft;
    
    if (!CGPointEqualToPoint(self.layer.anchorPoint, CGPointMake(0, 0))) {
        CGRect previousFrame = self.frame;
        self.layer.anchorPoint = CGPointMake(0, 0);
        self.frame = previousFrame;
    }
    
    self.layer.transform = [self homographyMatrixFromSource:src destination:dst];
}

@end
