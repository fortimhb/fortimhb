%% Fixed Income Securities
Settle          = '13-Dec-2016';
Maturity        = '01-Sep-2018';
CouponRate   = 0.08; %twice per year coupon is default 
%Face value is assumed to be 100 (MATLAB)

%% cfdates computes actual cash flow payment dates - when the coupon will be paid out
CFlowDates = datestr(cfdates(Settle, Maturity))

%CFlowDates = datestr(cfdates(Settle, Maturity, 4)) - coupon paid every 4 months

%% bndyield compute the yield of a bond - COMPUTES YIELD TO MATURITY 
Price        = 930;
Yield = bndyield(Price, CouponRate, Settle, Maturity,'Face',1000) %face value as optional setting (defualt of 100)
% 'Face' 'Period' 'Basis' to customize bndyield

% alternative syntax
Yield = bndyield(Price, CouponRate, Settle, Maturity,[],[],[],[],[],[],[],1000)

%% instead of using bndyield, use basic financial funcions to get the same result
CashFlow = [-(930+22.762), 40, 40, 40, 1040];
CashFlowDates = ['13-Dec-2016'
                 '01-Mar-2017'
                 '01-Sep-2017'
                 '01-Mar-2018'
                 '01-Sep-2018'];
Return = xirr(CashFlow, CashFlowDates);
nomrr(Return, 2)

%% bndprice  compute the price of a bond
format shortG
Yield           = 0.03;
[Price, AccruedInt] = bndprice(Yield, CouponRate, Settle,Maturity,'Face',1000)

%%%%%%%%%%%%DURATION%%%%%%%%%%%%%%

%% bnddury bond duration given yield
Yield           = 0.1;
[ModDuration, YearDuration, PerDuration] = bnddury(Yield,CouponRate, Settle, Maturity)
Settle          = '13-May-2008';
[ModDuration, YearDuration, PerDuration] = bnddury(Yield,CouponRate, Settle, Maturity)

%% bnddurp bond duration given price
Settle          = '13-Dec-2016';
Price           = 930;
[ModDuration,YearDuration,PerDuration] = bnddurp(Price,CouponRate,Settle,Maturity,'Face',1000)
Yield           = 0.1265;
[ModDuration,YearDuration,PerDuration] = bnddury(Yield,CouponRate,Settle,Maturity)
%bnddurp = bond duration given price
%bnddury = bond duration given yield 

%% bndconvy bond convexity given yield
Settle          = '13-Dec-2016';
Yield           = 0.1;
[ModConvexity, PerModConvexity] = bndconvy(Yield,CouponRate, Settle, Maturity)
Settle          = '13-May-2018';
[ModConvexity, PerModConvexity] = bndconvy(Yield,CouponRate, Settle, Maturity)

%% bndconvp bond convexity given price
Settle          = '13-Dec-2016';
Price           = 930;
[ModConvexity, PerModConvexity] = bndconvp(Price,CouponRate, Settle, Maturity,'Face',1000)
Yield           = 0.1265;
[ModConvexity, PerModConvexity] = bndconvy(Yield,CouponRate, Settle, Maturity)


%% impact of a change in the yield
DeltaY = .05 %CHANGE IN INTEREST RATE
DeltaP_perc = ModDuration*DeltaY-(ModConvexity/2)*DeltaY^2 %SECOND ORDER APPROXIMATION, %CHANGE IN PRESENT VALUE


%Mod_... - modified
%Per_Mod...- periodic modified