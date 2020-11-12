function [ output ] = RFMQSMCMultiState180731( input1,input2,input4 )
%UNTITLED8 此处显示有关此函数的摘要
%   此处显示详细说明
%numAgent=input1;
%numCursor=input2;
%game=input3;
%round=input4;

%%%%%%%%%%%%%%%%%%
%parameter setting
stop=input4;
alfaQ=0.5;
alfaF=0.01;
%alfaW=0.005;
gamma=1;

deltaD=0.5;
deltaL=1.1;

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
currentState=100000*x0+1000*y0+100*c0+10*v0+w0;


cursor=zeros(numAgent,numState,numCursor);
for j=1:numState
    for k=1:numCursor
        cursor(1,j,k)=(k)/(numCursor+1);
        cursor(2,j,k)=(k)/(numCursor+1);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Norm(mean,variance)=N(maxCursor,leagth)
length0=1/3;
length=ones(numAgent,numState)*length0;

maxCursorOld=-1.*ones(numAgent,numState);
maxQvalueOld=-1.*ones(numAgent,numState);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Q and others
Qvalue=zeros(numAgent,numState,numCursor);
Qmax=zeros(numAgent,numState,numCursor);
Fia=ones(numAgent,numState,numCursor);
Eia=zeros(numAgent,numState,numCursor);
actionM=randsrc(numAgent,numState,[1:numCursor;ones(1,numCursor)./numCursor]);
action=zeros(numAgent,1);%%
Qtemp=zeros(numCursor,1);%%
Etemp=zeros(numCursor,1);
Ctemp=zeros(numCursor,1);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%used to adjust exploring rate
epsiSample=0.5.*ones(numAgent,numState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%update



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update
N=1;
kk=zeros(numAgent,numState);
Ntime=0;% used to verify the number of state during a learning round
while N<stop
    %alfaQ=alfaQ*0.999;
    Ntime=Ntime+1;
    %chocie action
    for i=1:numAgent
        kk(i,currentState)=kk(i,currentState)+1;
        epsi=10/(10+kk(i,currentState));
        exorNot(i)=randsrc(1,1,[explorAlphabet;[1-epsi epsi]]);
        if exorNot(i)==1
            action(i)=actionM(i,currentState);
        else
            action(i)=randsrc(1,1,[actionAlphabet(i,:);ones(1,numCursor)./numCursor]);
        end
    end
    
    %corrent reword
    [nextState,Rcurrent,BoN]=boatTwogoalWithtime180820(currentState,[cursor(1,currentState,action(1)),cursor(2,currentState,action(2))]);
    

    
    %Q learn and action update
    for i=1:numAgent %program for agent i
        %maxQ=0;
        %maxmaxQ=0;
        %update Q
        if BoN==1
            % Rcurrent=Rcurrent*100/(100+Ntime);
            Qvalue(i,currentState,action(i))=Qvalue(i,currentState,action(i))*(1-alfaQ)+alfaQ*Rcurrent;
        else
            for k=1:numCursor
                %Qtemp(k)=Qmax(i,nextState,k);
                Qtemp(k)=Qvalue(i,nextState,k);
            end
            [~,maxQ]=maxandNum(Qtemp);
            %Qvalue(i,stateCurrent,action(i))=Qvalue(i,stateCurrent,action(i))*(1-alfaQ)+alfaQ*(Rcurrent+max(Qvalue(i,stateNext,:)));
            Qvalue(i,currentState,action(i))=Qvalue(i,currentState,action(i))*(1-alfaQ)+alfaQ*(Rcurrent+gamma*maxQ);
        end
%         for k=1:numCursor
%             Qtemp(k)=Qmax(i,nextState,k);
%             %Qtemp(k)=Qvalue(i,nextState,k);
%         end
%         [~,maxmaxQ]=maxandNum(Qtemp);
        if (Rcurrent+gamma*maxQ)>Qmax(i,currentState,action(i))
            Qmax(i,currentState,action(i))=Rcurrent+gamma*maxQ;
            Fia(i,currentState,action(i))=1;
        elseif (Rcurrent+gamma*maxQ)==Qmax(i,currentState,action(i))
            Fia(i,currentState,action(i))=Fia(i,currentState,action(i))*(1-alfaF)+alfaF;
        else
            Fia(i,currentState,action(i))=Fia(i,currentState,action(i))*(1-alfaF);
        end
        Eia(i,currentState,action(i))=(1-Fia(i,currentState,action(i)))*Qvalue(i,currentState,action(i))+Fia(i,currentState,action(i))*Qmax(i,currentState,action(i));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %epslon-greedy
        for k=1:numCursor
            Qtemp(k)=Eia(i,currentState,k);
        end
        [actionM(i,currentState),~]=maxandNum(Qtemp);
        
        if kk(i,currentState)==200
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %update mean and variance
            temp=zeros(numCursor,2);%sortrows按列排序
            for k=1:numCursor
                temp(k,1)=cursor(i,currentState,k);
                temp(k,2)=Eia(i,currentState,k);
            end
            temp=sortrows(temp,2);
            maxCursor=temp(numCursor,1);
            maxQvalue=temp(numCursor,2);
            if abs(maxCursor-maxCursorOld(i,currentState))>0.1
            %if abs(maxCursor-maxCursorOld(i,currentState))>3*max(length(i,currentState),0.001)
                length(i,currentState)=length0;
                maxCursorOld(i,currentState)=maxCursor;
            elseif maxQvalue-maxQvalueOld(i,currentState)>-0.005
                length(i,currentState)=max(length(i,currentState)*deltaD,0.01);
            else
                length(i,currentState)=min(length0,length(i,currentState)*deltaL);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %resample
            for k=1:numCursor
                Ctemp(k)=cursor(i,currentState,k);
                Etemp(k)=Eia(i,currentState,k);
            end
            [Ctemp,Qtemp]=resampleSCCepslon(Ctemp,Etemp,[epsiSample(i,currentState),length(i,currentState)]);
            %resampleSCCepslon (l,l,[1,2])
            for k=1:numCursor
                cursor(i,currentState,k)=Ctemp(k);
                Qvalue(i,currentState,k)=Qtemp(k);
                Qmax(i,currentState,k)=0;
                Fia(i,currentState,k)=1;
                Eia(i,currentState,k)=Qtemp(k);
            end
            maxQvalueOld(i,currentState)=maxQvalue;
            epsiSample(i,currentState)=epsiSample(i,currentState)*0.5;
            kk(i,currentState)=0;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %nextState
    currentState=nextState;
    
    
    %%%%%%%%%
    %for debug
    if BoN==1
        %alfaQ=max(alfaQ*0.999,0.1);
        if mod(N,5000)==0
            alfaQ=alfaQ*0.99;
            Rcurrent-0.1*Ntime
            N
        end
        rewardAll(N)=Rcurrent-Ntime*0.1;
        %rewardAll(N)=max(Qvalue(1,stateCurrent,:));
        N=N+1;
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

