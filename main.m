%A=RFMQforSMCMultiState(2,5);
stop=200000;
A=zeros(1,stop);
C=zeros(1,stop);
B=A;
for i=1:10
    A=RFMQSMCMultiState180731(2,5,stop);
    B=A./i+B.*(i-1)/i;
end

subplot(1,2,1)
plot(1:100:stop-1,B(1,1:100:stop-1));
%[~,num]=size(B);
for i=1000:stop-1
    C(i)=mean(B(i-999:i));
end
subplot(1,2,2)
plot(1000:100:stop-1,C(1000:100:stop-1));