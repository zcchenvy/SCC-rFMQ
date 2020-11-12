function [ output1,output2, output3] = boatReward0824( input1,input2 )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
%input1: state -- s (x,y,v,w) , (x,y): position; v: linear velocity; w: angular velocity 
% x (1-50)(100); y (1-100)(100); v (2-5)(10); w (-pi/3,pi/3)(10)
%input2: joint action -- (av,aw),   av: linear acceleration; aw: angular acceleration
% av 
%output1: next state --
%output2: current reward
%output3: wether or not reach the border
fc=4;
y=floor(input1(1)/10000);
x=mod(floor(input1(1)/100),100);
v=mod(floor(input1(1)/10),10);
w=mod(input1(1),10);
av=-1+3*input2(1);%av (-1,2)
aw=-1+2*input2(2);%aw (-1,1)
%%%%%%%%%%

%V=max(min(v+av,1),3);
%W=max(min(w+aw,-pi/3),pi/3);
%X=max(1,min(100,round(x+V*cos(W))));
V=0.3*v+2;
W=pi*w/15-pi/3;
X=x;
Y=y;


i=1;
while i<100 && X<50 && Y<100 && Y>1
    V1=min(max(V+0.01*av,1+0.00001),2.99999);
    W=min(max(W+0.01*aw,-pi/3+0.00001),pi/3-0.00001);
    ext=fc*(X/50-(X/50)^2);
    X=X+0.01*(V+V1)*cos(W)/2;
    Y=Y+0.01*(V+V1)*sin(W)/2+0.01*ext;
    V=V1;
    i=i+1;
end
%     X=max(1,min(100,X+V*cos(W)));
%     Y=max(1,min(100,Y+V*sin(W)+ext));
%X=round(X);
%Y=round(Y);
V1=floor(10*V/3-20/3);
W1=floor(5+15*W/pi);


%output1==zeros(1,4);


if X<50 && Y<100 && Y>1
%    output1=10000*floor(Y)+100*floor(X)+10*V1+W1;
    output1=10000*floor(Y)+100*floor(X)+10*V1+W1;
    output2=0;
    output3=0;
elseif X>=50 && abs(Y-50)<=9     
    output1=10000*50+100*1+10*5+5;
    output2=20-2*abs(Y-50);
    output3=1;
%elseif xy(1)<200 && (xy(2)==200 || xy(2)==1)
%    output2=-200;    
else
    output1=10000*50+100*1+10*5+5;
    output2=0; 
    output3=1;
end



    
    
    
end

