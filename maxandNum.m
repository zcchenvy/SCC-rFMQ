function [ maxNum,maxValue] = maxandNum( input )
%UNTITLED6 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[m,~]=size(input);
Kn=0;Kv=-10000;K=0;
for i=1:m
    if input(i)>Kv
        Kv=input(i);
%        Kn=i;
    end
end
for i=1:m
    if Kv==input(i)
        K=K+1;
    end
end
alpha=zeros(K,1);
kl=1;
for i=1:m
    if Kv==input(i)
        alpha(kl)=i;
        kl=kl+1;
    end
end
Kn=alpha(randi([1 K],1,1));
maxNum=Kn;
maxValue=Kv;
end

