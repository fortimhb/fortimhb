data = [1.25 2.3 2.6 3 3.9 4.1 8.2]';
%% simple default kernel densities, using the specialized function ksdensity or 
%% the generic function fitdist with option 'Kernel' (check help for both) 
[fi,xi] = ksdensity(data);
plot(xi,fi)
%
pd_kernel = fitdist(data,'Kernel');
mean(pd_kernel)
median(pd_kernel)
std(pd_kernel)
mean(data)
median(data)
std(data)
x = -10:.1:20;
f = pdf(pd_kernel,x);
plot(x,f)

%% details on the role of kernel function and bandwidth
%% kernel 'normal' (default)
kern='normal';
%% try different bandwidths from 0.1 to 4 (if you set bandw=0 the program below uses the 
%% default bandwidth, i.e. optimized), gaussian kernel
bandw=1;
figure
%% if you want to show the histogram, remove % in the two lines below
%histogram(data,'normalization','pdf')
%hold on
if bandw==0
    pd_kernel = fitdist(data,'Kernel','kernel',kern);
    bandw=pd_kernel.Bandwidth
else
    pd_kernel = fitdist(data,'Kernel','kernel',kern,'BandWidth',bandw);
end
x = -10:.1:20;
f = pdf(pd_kernel,x);
plot(x,f,'k-','LineWidth',2)
% Plot each individual pdf and scale its appearance on the plot
hold on
for i=1:7
    pd = makedist('Normal','mu',data(i),'sigma',bandw);
    y = pdf(pd,x);
    y = y/7;
    plot(x,y,'b:')
end
hold off

%%
%% kernel 'box' (Uniform)
kern='box';
%% try different bandwidths from 0.1 to 4 (bandw=0: default-> optimized), uniform kernel
bandw=1;
figure
%histogram(data,'normalization','pdf')
%hold on
if bandw==0
    pd_kernel = fitdist(data,'Kernel','kernel',kern);
    bandw=pd_kernel.Bandwidth
else
    pd_kernel = fitdist(data,'Kernel','kernel',kern,'BandWidth',bandw);
end
x = -10:.01:20;
f = pdf(pd_kernel,x);
plot(x,f,'k-','LineWidth',2)
% Plot each individual pdf and scale its appearance on the plot 
% NOTE: the variance of the uniform between -b and b is (b^2)/3. Therefore, if we want
% that the standard deviation is equal to bandw, we have to set b=bandw*sqrt(3)
hold on
for i=1:7
    pd = makedist('Uniform','lower',data(i)-bandw*sqrt(3),'upper',data(i)+bandw*sqrt(3));
    y = pdf(pd,x);
    y = y/7;
    plot(x,y,'b:')
end
hold off

%%
%% kernel 'triangle'
kern='triangle';
%% try different bandwidths from 0.1 to 4 (bandw=0: default-> optimized), triangular kernel
bandw=4;
figure
%histogram(data,'normalization','pdf')
%hold on
if bandw==0
    pd_kernel = fitdist(data,'Kernel','kernel',kern);
    bandw=pd_data.Bandwidth
else
    pd_kernel = fitdist(data,'Kernel','kernel',kern,'BandWidth',bandw);
end
x = -10:.1:20;
f = pdf(pd_kernel,x);
plot(x,f,'k-','LineWidth',2)
% Plot each individual pdf and scale its appearance on the plot
% NOTE: the variance of the symmetric triangular between -b and b is (b^2)/6. Therefore, if we want
% that the standard deviation is equal to bandw, we have to set b=bandw*sqrt(6)
hold on
for i=1:7
    pd = makedist('triangular','a',data(i)-bandw*sqrt(6),'b',data(i),'c',data(i)+bandw*sqrt(6));
    y = pdf(pd,x);
    y = y/7;
    plot(x,y,'b:')
end
hold off
