function [output1,output2] = resampleSCCepslon( input1,input2,input3 )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input1=cursor, sorted  and belong to [0,1]
%input2=weight
%input3=Qvalue
%input4=length of minmix bandwidth
cursor=input1;
Qvalue=input2;
epsi=input3(1);
length=input3(2);

[numCursor,~]=size(input1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%output1=newCursor
%output2=newWeight
%output3=newQvalue
%output4=maxCursor
output1=zeros(numCursor,1);
output2=zeros(numCursor,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp=zeros(numCursor,2);%sortrows∞¥¡–≈≈–Ú
temp(:,1)=cursor;
temp(:,2)=Qvalue;

temp2=sortrows(temp,2);
maxCursor=temp2(numCursor,1);
resampNum=floor(2*numCursor/3);
%resampNum=numCursor-1;
for i=1:resampNum
    exorNot=randsrc(1,1,[[1 2];[1-epsi epsi]]);
    if exorNot==1
        %      c1=maxCursor-length;
        %      c2=maxCursor+length;
        %      temp2(i,1)=c1+(c2-c1)*rand(1,1);
        temp2(i,1)=maxCursor+length*randn(1,1);
        if temp2(i,1)<0
            temp2(i,1)=0;
        elseif temp2(i,1)>1
            temp2(i,1)=1;
        end
    else
        temp2(i,1)=rand(1,1);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp3=sort(temp2(:,1));


%output1(1)=temp3(1,1);
km=1;kn=2;
while km<numCursor-1&&kn<numCursor+1&&km<numCursor+1
    kn=km+1;
    while kn<numCursor+1&&temp3(kn,1)==temp3(km,1)
        kn=kn+1;
    end
    if kn>km+1
        if kn<=numCursor
            for j=km+1:kn-1
                c1=max(temp3(km,1)-0.1,temp3(km,1)/2);
                c2=min((temp3(kn,1)+temp3(km,1))/2,temp3(km,1)+0.1);
                temp3(j,1)=c1+(c2-c1)*rand(1,1);
            end
        else
            for j=km+1:numCursor
                c1=max(temp3(km,1)-0.1,temp3(km,1)/2);
                c2=min((1+temp3(km,1))/2,temp3(km,1)+0.1);
                temp3(j,1)=c1+(c2-c1)*rand(1,1);
            end
        end
    end
    km=kn;
    
end

output1(:)=sort(temp3(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output2(:)=mean(Qvalue)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

