function output = resample( input1,input2,input3 )
%UNTITLED6 此处显示有关此函数的摘要
%input1=cursor, sorted  and belong to [0,1]
%input2=weight
%input3=Qvalue
%input4=length of minmix bandwidth

%output1=newCursor
%output2=newWeight
%output3=newQvalue

cursor=input1;
weight=input2;
%Qvalue=input3;
length=input3;
[~,numCursor]=size(input1);
K=zeros(2,numCursor);
j=1;
%newCursor=sort(randsrc(1,numCursor,[cursor;weight]),'descend');
epsi=randsrc(1,1,[[1 2];[0.9 0.1]]);
if epsi==1
    newCursor=sort(randsrc(1,numCursor,[cursor;weight]));
else
    newCursor=sort(randsrc(1,numCursor,[cursor;ones(1,numCursor)./numCursor]));
end

%output3=zeros(1,numCursor);
for i=1:numCursor %weight
    while newCursor(i)~=cursor(j)
        j=j+1;
    end
    %    weight(i)=input2(j);
    %    output3(i)=Qvalue(j);
    j=1;
end
%weight normalized
%sumweight=sum(weight);
%weight(numCursor)=1;
%for i=1:numCursor-1 %weight
%    weight(i)=floor(1000*weight(i)/sumweight)/1000;
%    if weight(i)<0
%        weight(i)=0;
%    end
%    weight(numCursor)=weight(numCursor)-weight(i);
%end
%output2=zeros(1,numCursor);
%output2=weight;
j=1;
%count the number of each value
for i=1:numCursor
    while K(2,j)~=0&&newCursor(i)>K(1,j)
        j=j+1;
    end
    if K(2,j)==0
        K(1,j)=newCursor(i);
        K(2,j)=K(2,j)+1;
        %        K(3,j)=weight(i);
    elseif newCursor(i)==K(1,j)
        K(2,j)=K(2,j)+1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sample=K(1,1:j);
output=zeros(1,numCursor);
%
k=1;
if j==1
    c1=max(K(1,1)-length/2,0);
    c2=min(K(1,1)+length/2,1);
    output(1)=K(1,1);
    if K(2,1)>1
        output(2:K(2,1))=sort(c1+(c2-c1)*rand(1,K(2,1)-1));
    end
elseif j==2
    c1=max(K(1,1)-length/2,0);
    c2=min(K(1,1)+length/2,(K(1,1)+K(1,2))/2);
    output(1)=K(1,1);
    if K(2,1)>1
        output(2:K(2,1))=sort(c1+(c2-c1)*rand(1,K(2,1)-1));
    end
    k=k+K(2,1);
    c1=max(K(1,2)-length/2,(K(1,1)+K(1,2))/2);
    c2=min(K(1,2)+length/2,1);
    output(k)=K(1,2);
    if K(2,2)>1
        output(k+1:k+K(2,2)-1)=sort(c1+(c2-c1)*rand(1,K(2,2)-1));
    end
else
    c1=max(K(1,1)-length/2,0);
    c2=min(K(1,1)+length/2,(K(1,1)+K(1,2))/2);
    output(1)=K(1,1);
    if K(2,1)>1
        output(2:K(2,1))=sort(c1+(c2-c1)*rand(1,K(2,1)-1));
    end
    k=k+K(2,1);
    for i=2:j-1
        c1=max(K(1,i)-length/2,(K(1,i)+K(1,i-1))/2);
        c2=min(K(1,i)+length/2,(K(1,i)+K(1,i+1))/2);
        output(k)=K(1,i);
        if K(2,i)>1
            output(k+1:k+K(2,i)-1)=sort(c1+(c2-c1)*rand(1,K(2,i)-1));
        end
        k=k+K(2,i);
    end
    c1=max(K(1,j)-length/2,(K(1,j)+K(1,j-1))/2);
    c2=min(K(1,j)+length/2,1);
    output(k)=K(1,j);
    if K(2,j)>1
        output(k+1:k+K(2,j)-1)=sort(c1+(c2-c1)*rand(1,K(2,j)-1));
    end
end
output=sort(output);




end

