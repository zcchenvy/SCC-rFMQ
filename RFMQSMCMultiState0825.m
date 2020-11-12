function [ output ] = RFMQSMCMultiState0825( input1,input2,input3 )
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
%numAgent=input1;

%%%%%%%%%%%%%%%%%%
%parameter setting
stop=input3;
alfaQ=0.9;
alfaF=0.001;
alfaW=0.005;
gamma=0.9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize
numAgent=input1;
numCursor=input2;
numState=6000000;

%(x0,y0,c0,v0,w0)  start state
x0=1;
y0=50;
c0=5;
v0=5;
w0=5;
stateCurrent=100000*x0+1000*y0+100*c0+10*v0+w0;
%stateCurrent=10000*y0+100*x0+10*v0+w0;
BoN=0;
%stateNext=0;


%game=input3;

cursor=zeros(numAgent,numState,numCursor);


for j=1:numState
    for k=1:numCursor
        cursor(1,j,k)=(k)/(numCursor+1);
        cursor(2,j,k)=(k)/(numCursor+1);
    end
end
%newCursor=zeros(numAgent,numCursor);
Qvalue=zeros(numAgent,numState,numCursor);
weight=ones(numAgent,numState,numCursor)./numCursor;
%variance=zeros(numAgent,1);
length=ones(numAgent,numState,1)./3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
%Qvalue=zeros(numAgent,numAction);
Qmax=zeros(numAgent,numState,numCursor);
Fia=ones(numAgent,numState,numCursor);
Eia=zeros(numAgent,numState,numCursor);
Qmmmmm=zeros(numCursor,1);
Qmm=zeros(numCursor,1);
action=zeros(numAgent,1);
actionM=zeros(numAgent,1);
policy=zeros(1,numCursor);
cursorn=zeros(1,numCursor);



maxQ=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%used to adjust exploring rate
Qaverage=zeros(numAgent,numState);
QaverageB=zeros(numAgent,numState);
numB=ones(numAgent,numState);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ohter values
%weightAll=zeros(numAgent,numCursor,stop);
%actionAll=zeros(numAgent,numState,stop);

rewardAll=zeros(1,stop);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%
actionAlphabet=zeros(numAgent,numCursor);
for i=1:numAgent
    actionAlphabet(i,:)=1:1:numCursor;
end
explorAlphabet=[1 2];
exorNot=zeros(numAgent,1);
%%%%%%%%%%%%%%%%%%
variance=zeros(numAgent,1);

%%%%%%%%%%%%%%%%%%
epsi=0.1;
%update
N=1;
Ntime=0;
while N<stop
    
    Ntime=Ntime+1;
    %chocie action
    for i=1:numAgent
%        epsi=1000/(10000+N);
        exorNot(i)=randsrc(1,1,[explorAlphabet;[1-epsi epsi]]);
        if exorNot(i)==1
            for k=1:numCursor
                policy(k)=weight(i,stateCurrent,k);
            end
            action(i)=randsrc(1,1,[actionAlphabet(i,:);policy]);
        else
            action(i)=randsrc(1,1,[actionAlphabet(i,:);ones(1,numCursor)./numCursor]);
        end
    end
    
    %corrent reword
    [stateNext,Rcurrent,BoN]=boatTwogoal180730(stateCurrent,[cursor(1,stateCurrent,action(1)),cursor(2,stateCurrent,action(2))]);
    
    for i=1:numAgent %program for agent i
        %update Q
        if BoN==1
            %Rcurrent=Rcurrent*100/(100+Ntime);
            Qvalue(i,stateCurrent,action(i))=Qvalue(i,stateCurrent,action(i))*(1-alfaQ)+alfaQ*Rcurrent;
            maxQ=0;
        else
            for kk=1:numCursor
                Qmm(kk)=(Qvalue(i,stateNext,kk));
            end
            [~,maxQ]=maxandNum(Qmm);
            %Qvalue(i,stateCurrent,action(i))=Qvalue(i,stateCurrent,action(i))*(1-alfaQ)+alfaQ*(Rcurrent+max(Qvalue(i,stateNext,:)));
            Qvalue(i,stateCurrent,action(i))=Qvalue(i,stateCurrent,action(i))*(1-alfaQ)+alfaQ*(Rcurrent+gamma*maxQ);
        end
        if (Rcurrent+gamma*maxQ)>Qmax(i,stateCurrent,action(i))
            Qmax(i,stateCurrent,action(i))=Rcurrent+maxQ;
            Fia(i,stateCurrent,action(i))=1;
        elseif (Rcurrent+gamma*maxQ)==Qmax(i,stateCurrent,action(i))
            Fia(i,stateCurrent,action(i))=Fia(i,stateCurrent,action(i))*(1-alfaF)+alfaF;
        else
            Fia(i,stateCurrent,action(i))=Fia(i,stateCurrent,action(i))*(1-alfaF);
        end
        Eia(i,stateCurrent,action(i))=(1-Fia(i,stateCurrent,action(i)))*Qvalue(i,stateCurrent,action(i))+Fia(i,stateCurrent,action(i))*Qmax(i,stateCurrent,action(i));
        
        
        %update policy
        for k=1:numCursor
            Qmmmmm(k)=Eia(i,stateCurrent,k);
        end
        [actionM(i),~]=maxandNum(Qmmmmm);
        weight(i,stateCurrent,actionM(i))=1;
        for j=1:numCursor
            if j~=actionM(i)
                weight(i,stateCurrent,j)=floor(1000*(weight(i,stateCurrent,j)-alfaW))/1000;
                if weight(i,stateCurrent,j)<0
                    weight(i,stateCurrent,j)=0;
                end
                weight(i,stateCurrent,actionM(i))=weight(i,stateCurrent,actionM(i))-weight(i,stateCurrent,j);
            end
        end
        
        %store
        %weightAll(i,:,N)=weight(i,:);
        %actionAll(i,N)=cursor(i,action(i));
        
        %resample condition
        for j=1:numCursor
            if weight(i,stateCurrent,j)<0.08
                variance(i)=variance(i)+1;
            end
        end
        %resample
        if mod(N,100)==0%variance(i)>numCursor/3
            for k=1:numCursor
                Qaverage(i,stateCurrent)=Qaverage(i,stateCurrent)+Qvalue(i,stateCurrent,k)*weight(i,stateCurrent,k);
            end
            %Qaverage(i,stateCurrent)=Qvalue(i,stateCurrent,:)*weight(i,stateCurrent,:)';
            if Qaverage(i,stateCurrent)>QaverageB(i,stateCurrent)
                length(i,stateCurrent)=length(i,stateCurrent)*2/3;
            elseif Qaverage(i,stateCurrent)==QaverageB(i,stateCurrent)
                length(i,stateCurrent)=length(i,stateCurrent)*2.5/3;
            else
                length(i,stateCurrent)=min(length(i,stateCurrent)*2.25/2,1/2);
            end
            
            for k=1:numCursor
                policy(k)=weight(i,stateCurrent,k);
                cursorn(k)=cursor(i,stateCurrent,k);
            end
            cursorn= resample0826new(cursorn,policy,length(i,stateCurrent));
            for k=1:numCursor
                cursor(i,stateCurrent,k)=cursorn(k);
            end
            
            weight(i,stateCurrent,:)=ones(1,1,numCursor)./numCursor;
            Qvalue(i,stateCurrent,:)=2.*Qaverage(i,stateCurrent)/3;
            QaverageB(i,stateCurrent)=(numB(i,stateCurrent)-1)*QaverageB(i,stateCurrent)/numB(i,stateCurrent)+Qaverage(i,stateCurrent)/numB(i,stateCurrent);
            numB(i,stateCurrent)=numB(i,stateCurrent)+1;
            Qaverage(i,stateCurrent)=0;
            Qmax(i,stateCurrent,:)=0;
            Fia(i,stateCurrent,:)=1;
        end
        variance(i)=0;
        
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %nextState
    stateCurrent=stateNext;
    if BoN==1 
        %rewardAll(N)=Qvalue(1,stateCurrent,action(1));
        %stateCurrent=100*y0+x0;
        if mod(N,5000)==0
            Rcurrent;
   %         for k=1:numCursor
   %             Qaverage(1,stateCurrent)=Qaverage(1,stateCurrent)+Qvalue(1,stateCurrent,k)*weight(1,stateCurrent,k);
   %         end
            Qaverage(1,stateCurrent)
            N
        end
        rewardAll(N)=Rcurrent;
        %rewardAll(N)=max(Qvalue(1,stateCurrent,:));
        N=N+1;
        BoN=0;
        Ntime=0;
    %else
    %    stateCurrent=stateNext;
    end
    
    
end

%hold on
%for i=1:numAgent
%plot(1:stop-1,rewardAll(1,1:stop-1));
 %  plot(1:stop-1,weightAll(i,2,1:stop-1));
%end
%hold off
output=rewardAll;

end

