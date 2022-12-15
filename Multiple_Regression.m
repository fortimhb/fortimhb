houses=xlsread('real_estate.xlsx');
houses_tab=array2table(houses(:,2:8),'VariableNames',{'Price','House_Size','Lot_size','Beds','Baths','Stories','Garage'});


%% CHECKING ASSUMPTIONS IN THE SIMPLE REGRESSION FRAMEWORK
y=houses(:,2);
X=houses(:,3);
model = fitlm(X,y)
% or
model = fitlm(houses_tab,'ResponseVar','Price','PredictorVars',{'House_Size'})
% multicollinearity: not relevant in the simple regression framework
% functional form
model2 = fitlm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size'})
plotSlice(model2)
% heteroskedasticity
plotResiduals(model,'fitted')
% heteroskedasticity test
res=model.Residuals.raw;
houses_tab.logres2=log(res.^2);
model_var = fitlm(houses_tab,'ResponseVar','logres2','PredictorVars',{'House_Size'})
% in this case we reject homoskedasticity. Below WLS is illustrated
vars = exp(model_var.Fitted);
D=diag(vars);
[coeff,se,vcv_beta]=fgls(X,y,'innovcov0',D,'display','final')

% normality
histfit(model.Residuals.Raw)
plotResiduals(model,'probability')
% normality test
skewness(model.Residuals.Raw)
kurtosis(model.Residuals.Raw)
[h,p,jbstat,critval]=jbtest(model.Residuals.Raw)


%%%%% logarithmic model in the simple regression framework
houses_tab.logPrice=log(houses_tab.Price);
houses_tab.logHouse_Size=log(houses_tab.House_Size);
model_log = fitlm(houses_tab,'ResponseVar','logPrice','PredictorVars',{'logHouse_Size'})

% functional form
model_log2 = fitlm(houses_tab,'quadratic','ResponseVar','logPrice','PredictorVars',{'logHouse_Size'})
% heteroskedasticity
plotResiduals(model_log,'fitted')
% heteroskedasticity test
res=model_log.Residuals.raw;
houses_tab.logres2=log(res.^2);
model_var = fitlm(houses_tab,'ResponseVar','logres2','PredictorVars',{'logHouse_Size'})
% in this case we do not reject homoskedasticity. No need for WLS then!
% normality
histfit(model_log.Residuals.Raw)
plotResiduals(model_log,'probability')
% normality test
skewness(model_log.Residuals.Raw)
kurtosis(model_log.Residuals.Raw)
[h,p,jbstat,critval]=jbtest(model_log.Residuals.Raw)



%%%% CHECKING ASSUMPTIONS IN THE MULTIPLE REGRESSION FRAMEWORK
y=houses(:,2);
XM=houses(:,3:8);
modelM = fitlm(XM,y)
% or preferably
modelM = fitlm(houses_tab,'ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})
% or equivalently
modelM = fitlm(houses_tab,'Price~1+House_Size+Lot_size+Beds+Baths+Stories+Garage','CategoricalVar',{'Stories'})
%%% multicollinearity diagnostics
% correlation
R = corrcoef(XM)
% or preferably
[R_tab,PValue] = corrplot(houses_tab(:,2:7),'testR','on')
% condition number
EV=eig(XM'*XM)
cond_num = sqrt(EV(6)/EV(1))
% or
cond_num = cond(XM)
% variance inflation factors: instead of running as many regression as the regressors
% (below I illustrate the first), it is possible to exploit the
% relationship between the VIF's and the diagonal elements of the inverse
% of the correlation matrix
y1=houses(:,3:3);
X1=houses(:,4:8);
mod1 = fitlm(X1,y1);
VIF1=1/(1-mod1.Rsquared.Ordinary)
VIF = diag(inv(R))


%%%% functional form (using the second line instead of the first you avoid a perfect collinearity problem)
modelM2 = fitlm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'})
modelM2 = fitlm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})
% linearity test: compare the linear and quadratic model
LR=2*(modelM2.LogLikelihood-modelM.LogLikelihood)
DoF_LR=modelM2.NumCoefficients-modelM.NumCoefficients
p_value_LR=1-chi2cdf(LR,DoF_LR)
% Instead of LR, we can do a Wald test for linearity
R=[zeros(20,7)  eye(20)];
[p_value_Wald,Wald,DoF_Wald]=coefTest(modelM2,R)
p_value_Wald=1-fcdf(Wald,DoF_Wald,modelM2.NumObservations-modelM2.NumCoefficients)

% automatic selection of the relevant i regressors using stepwise regression.
% Several critera are possible for inclusion/exclusion (see help)
model2step = stepwiselm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})
% BIC
model2step2 = stepwiselm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'},'Criterion','bic')
% Adjusted R^2
model2step3 = stepwiselm(houses_tab,'quadratic','ResponseVar','Price','PredictorVars',{'House_Size','Lot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'},'Criterion','adjrsquared')
% manual selection using Wilkinson notation: for example
modeladhoc1 = fitlm(houses_tab,'Price~1+House_Size+Lot_size+Beds+Baths+Stories+Garage+House_Size:Lot_size','CategoricalVar',{'Stories'})
modeladhoc2 = fitlm(houses_tab,'Price~1+House_Size*Lot_size+Beds+Baths+Stories+Garage','CategoricalVar',{'Stories'})
modeladhoc3 = fitlm(houses_tab,'Price~1+House_Size^2*Lot_size^2+Beds+Baths+Stories+Garage','CategoricalVar',{'Stories'})
% working out the marginal effects for model model2step
lot_star=0.3
bed_star=3
bath_star=3
garage_star=3
size_star=3000
weights = [0 1 0 0 0 0 0 lot_star bed_star bath_star garage_star ...
    0 0 0 0 0 0 2*size_star 0 0 0];
MEFF_size = weights*model2step.Coefficients.Estimate
sd_MEFF_size = sqrt(weights*model2step.CoefficientCovariance*weights')

% interactions analysis
plotInteraction(model2step,'House_Size','Beds','predictions')
plotInteraction(model2step,'House_Size','Baths','predictions')
plotInteraction(model2step,'House_Size','Garage','predictions')

% prediction with model model2step
plotSlice(model2step)

%%%%%% heteroskedasticity analysis (illustration in the model named model2step)
plotResiduals(model2step,'fitted')
% heteroskedasticity test
logres2=log(model2step.Residuals.raw.^2);
regressors = x2fx(table2array(model2step.Variables),model2step.Formula.Terms);
regressorsNC=regressors(:,2:21);
model_var=fitlm(regressorsNC,logres2)
T = table(model2step.CoefficientNames',table2array(model_var.Coefficients))
% in this case we reject homoskedasticity, therefore we proceed with WLS
fittedvar = exp(model_var.Fitted);
D=diag(fittedvar);
[coeff,se,vcv_beta]=fgls(regressorsNC,y,'innovcov0',D,'display','final');
T = table(model2step.CoefficientNames',coeff,se,coeff./se)
res=y-regressors*coeff;
std_res=res./sqrt(fittedvar)
T = table(res,std_res,sqrt(fittedvar))


%%%%%% normality
%%% based on OLS residuals
histfit(model2step.Residuals.Raw)
plotResiduals(model2step,'probability')
% normality test
skewness(model2step.Residuals.Raw)
kurtosis(model2step.Residuals.Raw)
[h,p,jbstat,critval]=jbtest(model2step.Residuals.Raw)

%%% based on standardized WLS residuals
histfit(std_res)
plotResiduals(std_res,'probability')
% normality test
skewness(std_res)
kurtosis(std_res)
[h,p,jbstat,critval]=jbtest(std_res)



%%%%%% logarithmic model
houses_tab_log=array2table([log(houses(:,2:4)) houses(:,5:8)],'VariableNames',{'lnPrice','lnHouse_Size','lnLot_size','Beds','Baths','Stories','Garage'});
model_log = fitlm(houses_tab_log,'ResponseVar','lnPrice','PredictorVars',{'lnHouse_Size','lnLot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})

%%%%%% functional form
model2_log = fitlm(houses_tab_log,'quadratic','ResponseVar','lnPrice','PredictorVars',{'lnHouse_Size','lnLot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})
% linearity test
R=[zeros(20,7)  eye(20)];
[p_value_Wald,Wald,DoF_Wald]=coefTest(model2_log,R)
p_value_Wald=1-fcdf(Wald,DoF_Wald,model2_log.NumObservations-model2_log.NumCoefficients)
% automatic selection of the relevant i regressors using stepwise regression (see help)
model2_logstep = stepwiselm(houses_tab_log,'quadratic','ResponseVar','lnPrice','PredictorVars',{'lnHouse_Size','lnLot_size','Beds','Baths','Stories','Garage'},...
'CategoricalVar',{'Stories'})
% prediction with model model2step
plotSlice(model2_logstep)
plotInteraction(model2_logstep,'lnHouse_Size','Beds','predictions')
plotInteraction(model2_logstep,'lnHouse_Size','Garage','predictions')


%%%%%% heteroskedasticity analysis (illustration in the model named model2_logstep)
plotResiduals(model2_logstep,'fitted')
% heteroskedasticity test
logres2=log(model2_logstep.Residuals.raw.^2);
regressors = x2fx(table2array(model2_logstep.Variables),model2_logstep.Formula.Terms);
regressorsNC=regressors(:,2:18);
model_var=fitlm(regressorsNC,logres2)
T = table(model2_logstep.CoefficientNames',table2array(model_var.Coefficients))
% in this case we accept homoskedasticity: no need for WLS then



% normality
histfit(model2_logstep.Residuals.Raw)
plotResiduals(model2_logstep,'probability')
% normality test
skewness(model2_logstep.Residuals.Raw)
kurtosis(model2_logstep.Residuals.Raw)
[h,p,jbstat,critval]=jbtest(model2_logstep.Residuals.Raw)




%%%%%% prediction with loglinear model
plotSlice(model2_logstep)
% or, to have more control (example predicting at the median)
x_star=quantile([log(houses(:,3:4)) houses(:,5:8)],.5)
% prediction (example: individual observation)
[yhat,conf_int]=predict(model2_logstep,x_star,'Alpha',0.05,'Prediction','observation','Simultaneous',false)
y_star_median=exp(yhat)
y_star_mean=exp(yhat+model2_logstep.MSE/2)
% confidence interval
exp(conf_int)
