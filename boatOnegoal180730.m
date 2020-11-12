function [ output1,output2, output3] = boatOnegoal180730( input1,input2 )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
%input1: state -- s (x,y,c,v,w) , (x,y) position; c angular; v linear velocity; w angular velocity 
% x (1-50)(100); y (1-100)(100); c (-pi/3,pi/3)(10); v (2-5)(10); w (-1,1)(10)
%input2: joint action -- (av,aw),   av: linear acceleration; aw: angular acceleration
% s=x*y*c*v*w=50*100*10*10*10=5000000
%output1: next state --
%output2: current reward
%output3: wether or not reach the border
fc=4;
x=floor(input1(1)/100000);
y=mod(floor(input1(1)/1000),100);
c=mod(floor(input1(1)/100),10);
v=mod(floor(input1(1)/10),10);
w=mod(input1(1),10);
av=-1+3*input2(1);%av (-1,2)
aw=-1+2*input2(2);%aw (-1,1)
%%%%%%%%%%

V=0.3*v+2;%%%f:[0,9]-->[2,5]
W=-1+0.2*w;%%%f:[0,9]-->[-1,1]
C=pi*c/15-pi/3;%%%f:[0,9]-->[-pi/3,pi/3]
X=x;
Y=y;

i=1;
while i<100 && X<50 && Y<100 && Y>1
    V1=min(max(V+0.01*av,1+0.00001),2.99999);
    W1=min(max(W+0.01*aw,-1+0.00001),1-0.00001);
    
    ext=fc*(X/50-(X/50)^2);
    C1=min(max(C+W1,-pi/3+0.00001),pi/3-0.00001);
    
    X=X+0.01*(V+V1)*cos(C/2+C1/2)/2;
    Y=Y+0.01*(V+V1)*sin(C/2+C1/2)/2+0.01*ext;
    V=V1;
    W=W1;
    C=C1;
    i=i+1;
end
%     X=max(1,min(100,X+V*cos(W)));
%     Y=max(1,min(100,Y+V*sin(W)+ext));
%X=round(X);
%Y=round(Y);
w=floor(5*W+5);%%%f:[-1,1]-->[0,10]
v=floor(10*V/3-20/3);%%%f:[2,5]-->[0,10]
c=floor(15*C/pi+5);%%%f:[2,5]-->[0,10]



%output1==zeros(1,4);


if X<50 && Y<100 && Y>1

    output1=100000*floor(X)+1000*floor(Y)+100*c+10*v+w;
    output2=0;
    output3=0;
elseif X>=50 && abs(Y-50)<=9     
    output1=100000*1+1000*50+100*5+10*5+5;
    output2=20-2*abs(Y-50);
    output3=1;
%elseif xy(1)<200 && (xy(2)==200 || xy(2)==1)
%    output2=-200;    
else
    output1=100000*1+1000*50+100*5+10*5+5;
    output2=0; 
    output3=1;
end



    
    
    
end

