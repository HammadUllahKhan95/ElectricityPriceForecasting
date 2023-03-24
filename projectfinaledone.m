clc;
clear;
close all;
warning off

day_ahead_2yr = readtable('Day-ahead_prices_201901010000_202101012359.csv');
day_ahead_2yr_fr = day_ahead_2yr(:,[1,2,6]);

day_ahead_rest = readtable('Day-ahead_prices_202101020000_202110252359.csv');
day_ahead_rest_fr = day_ahead_rest(:,[1,2,6]);

day_ahead_price_all = [day_ahead_2yr_fr; day_ahead_rest_fr];

Date = ["Mar 31, 2019";"Mar 29, 2020";"Mar 28, 2021";"Oct 27, 2019";"Oct 25, 2020"];
TimeOfDay = ["2:00 AM";"2:00 AM";"2:00 AM";"2:00 AM";"2:00 AM"];
France___MWh_ = [mean(day_ahead_price_all.France___MWh_(2138:2139));mean(day_ahead_price_all.France___MWh_(10874:10875));
    mean(day_ahead_price_all.France___MWh_(19610:19611));mean(day_ahead_price_all.France___MWh_(7178:7179));
    mean(day_ahead_price_all.France___MWh_(15914:15915))];
newRows = table(Date,TimeOfDay,France___MWh_);


final_data_day_ahead = [day_ahead_price_all(1:2138, :); newRows(1,:); day_ahead_price_all(2139:7177,:);newRows(4,:);
    day_ahead_price_all(7180:10874,:); newRows(2,:); day_ahead_price_all(10875:15913,:); newRows(5,:);
    day_ahead_price_all(15916:19610,:);newRows(3,:); day_ahead_price_all(19611:end,:) ];


final_day_ahead_demand_all = readtable('FRhourlyload.csv');
data = [final_day_ahead_demand_all final_data_day_ahead(:,"France___MWh_")];
data.Properties.VariableNames([1 2 3]) = {'Time' 'Day-ahead Load forecasts','Day-ahead prices'};


figure
plot(data{1:17544,"Day-ahead prices"},data{1:17544,"Day-ahead Load forecasts"},'.')
ylabel('Day-ahead Load forecasts');
xlabel('Day-ahead prices');
title('Year 2019-2020 Load vs Price Scatter Plot for all days')



data.Time = datetime(data.Time,'InputFormat','dd-MM-uuuu''HH:mm:ss');
data.day = weekday(datetime(data.Time));
data_sat = data(weekday(data.Time) == 7, :);
figure
plot(data_sat{1:2496,"Day-ahead prices"},data_sat{1:2496,"Day-ahead Load forecasts"},'.')
ylabel('Day-ahead Load forecasts');
xlabel('Day-ahead prices');
title('Year 2019-2020 Load vs Price Scatter Plot for all Saturdays')




data_hr10 = data(hour(data.Time) == 10, :);
figure
plot(data_hr10{1:731,"Day-ahead prices"},data_hr10{1:731,"Day-ahead Load forecasts"},'.')
ylabel('Day-ahead Load forecasts');
xlabel('Day-ahead prices');
title('Year 2019-2020 Load vs Price Scatter Plot for hour = 10:00 all days')


data.hour = timeofday(data.Time);
%Convert columns to arrays
elec_time = table2array(data(1:17544,'Time'));
elec_demand = table2array(data(1:17544,'Day-ahead Load forecasts'));
elec_price = table2array(data(1:17544,'Day-ahead prices'));


%Daily season for demand/load
figure
elec_day_demand = reshape(elec_demand,24,[]);
plot(timeofday(elec_time(1:24)),elec_day_demand)
xlabel('Time of day')
ylabel('Load/Demand')
title('Daily seasonality for demand/load')

%Daily season for price
figure
elec_day_price = reshape(elec_price,24,[]);
plot(timeofday(elec_time(1:24)),elec_day_price)
xlabel('Time of day')
ylabel('Price')
title('Daily seasonality for price')

%Weekly season for demand/load
figure
elec_week_demand_ext = [elec_demand; NaN*ones(24*4,1)];
elec_week_demand = reshape(elec_week_demand_ext,24*7,[]);
plot(elec_time(1:24*7),elec_week_demand')
datetick('x','ddd')
xlabel('Weekday')
ylabel('Load/Demand')
title('Weekly seasonality for demand/load')

%Weekly season for price
figure
elec_week_price_ext = [elec_price; NaN*ones(24*4,1)];
elec_week_price = reshape(elec_week_price_ext,24*7,[]);
plot(elec_time(1:24*7),elec_week_price')
datetick('x','ddd')
xlabel('Weekday')
ylabel('Price')
title('Weekly seasonality for price')

%Yearly Data
data19 = data(1:8760,:);
data20 = data(8761:17544,:);
data21 = data(17545:end,:);

%naive#1 d-7
%total hrs in 2021 = 7152 
%days = 7152/24 = 298
%2021 starts at 17545th row
T = 731; %cal length
test_len = 298;
npf7 = array2table(zeros(298*24,1));
npf7(1:end,1) = data(17544-167:end-168,"Day-ahead prices");
data21arrr  = table2array(data21(1:end,"Day-ahead prices"));
npf7arrr = table2array(npf7(1:end,1));

mae1 = mean(abs(data21arrr - npf7arrr));
rmse1 =(mean((data21arrr - npf7arrr).^2)).^0.5;

to_display1 = ['Mean Absolute Error for the Naive#1 model: ', num2str(mae1)];
disp(to_display1)
to_display2 = ['Root Mean Square Error for the Naive#1 model: ', num2str(rmse1)];
disp(to_display2)


%now lets do hour by hour mean error and rmse too for naive 7
tab = [];
for hour = 1:24
    p = table2array(data21(hour:24:end,"Day-ahead prices"));
    g = npf7arrr(hour:24:end);
    tab(hour,1:3) = [hour mean(abs(p - g)) (mean((p-g).^2)).^0.5];
end
tab = array2table(tab);
tab.Properties.VariableNames([1 2 3]) = {'Hour' 'MAE','RMSE'};


%naive17
npf17 = array2table(zeros(298*24,1));
z = 0;
for d = 1:7152
    d_for_hour = data21(d,:);
    if d_for_hour.('day') == 3 || d_for_hour.('day') == 4  || d_for_hour.('day') == 5  || d_for_hour.('day') == 6
        npf17(d,1) = data(17545-24+z,3);
        z = z + 1;
    else
        npf17(d,1) = data(17545-168+z,3);
        z = z + 1;
    end
end
data21arr  = table2array(data21(1:end,"Day-ahead prices"));
npf17arr = table2array(npf17(1:end,1));
mae2 = mean(abs(data21arr - npf17arr));
rmse2 =(mean((data21arr - npf17arr).^2)).^0.5;
disp(' ')
to_display1 = ['Mean Absolute Error for the Naive#2 model: ', num2str(mae2)];
disp(to_display1)
to_display2 = ['Root Mean Square Error for the Naive#2 model: ', num2str(rmse2)];
disp(to_display2)


%now lets do hour by hour mean error and rmse too for naive2 model
tab2 = [];
for hour = 1:24
    p = table2array(data21(hour:24:end,"Day-ahead prices"));
    g = npf17arr(hour:24:end);
    tab2(hour,1:3) = [hour mean(abs(p - g)) (mean((p-g).^2)).^0.5];
end
tab2 = array2table(tab2);
tab2.Properties.VariableNames([1 2 3]) = {'Hour' 'MAE','RMSE'};



%cal window parameters
mincol = zeros(size(data,1),1);
for i = 24:24:24696
    q = table2array(data(i-23:i,'Day-ahead prices'));
    s = min(q);
    t = ones(24,1);
    f = (s.*t);
    mincol(i+1:i+24) = f(1:24);
end
mincol = array2table(mincol);
mincol = mincol(25:24720,1);


hr_24_prev_day = zeros(size(data,1),1);
for i = 24:24:24696
    g = data(i,3);
    g = table2array(g);
    u = ones(24,1);
    h = (g.*u);
    hr_24_prev_day(i+1:i+24) = h(1:24);
end
hr_24_prev_day = array2table(hr_24_prev_day);
hr_24_prev_day = hr_24_prev_day(25:24720,1);

% tab3 = [];
% T = 731;
% PF = zeros(size(data(:,3)));
% for hour=1:24
%     p = table2array(data(hour:24:end,"Day-ahead prices"));
%     x = table2array(data(hour:24:end,"Day-ahead Load forecasts"));
%     k = table2array(mincol(hour:24:end,1));
%     z = table2array(hr_24_prev_day(hour:24:end,1));
%     Dsat = table2array(data(hour:24:end, "day")) == 7;
%     Dsun = table2array(data(hour:24:end, "day")) == 1;
%     Dmon = table2array(data(hour:24:end, "day")) == 2;
%     % AR(1) - estimation
%     pcal = p(1:T);
%     xcal = x(1:T);
%     kcal = k(1:T);
%     zcal = z(1:T);
%     Dsatcal = Dsat(1:T);
%     Dsuncal = Dsun(1:T);
%     Dmoncal = Dmon(1:T);
%     y = pcal(8:end); % for day d, d-1, d-7, load, min24hrbefore, dummies  ...
%     if hour == 24
%         X = [ones(T-7,1) pcal(7:end-1) pcal(1:end-7) xcal(8:end) kcal(7:end-1) Dsatcal(8:end) Dsuncal(8:end) Dmoncal(8:end)];
%         X_fut = [ones(length(p)-T,1) p(T:end-1) p(T-6:end-7) x(T+1:end) k(T:end-1) Dsat(T+1:end) Dsun(T+1:end) Dmon(T+1:end)];
%     else
%         X = [ones(T-7,1) pcal(7:end-1) pcal(1:end-7) xcal(8:end) kcal(7:end-1) zcal(7:end-1) Dsatcal(8:end) Dsuncal(8:end) Dmoncal(8:end)];
%         X_fut = [ones(length(p)-T,1) p(T:end-1) p(T-6:end-7) x(T+1:end) k(T:end-1) z(T:end-1) Dsat(T+1:end) Dsun(T+1:end) Dmon(T+1:end)];
%     end
%     % Regression, i.e., estimate betas
%     beta = regress(y,X);
%     % Make prediction
%     pf1 = zeros(size(p));
%     pf1(T+1:end,1) = X_fut*beta;
%     PF(hour:24:end) = pf1;
%     tab3(hour,1:3) = [hour mean(abs(p(T+1:end) - pf1(T+1:end))) (mean((p(T+1:end) - pf1(T+1:end)).^2)).^0.5];
% end
% tab3 = array2table(tab3);
% tab3.Properties.VariableNames([1 2 3]) = {'Hour' 'MAE','RMSE'};
% 
% mae3 = mean(abs(table2array(data(T*24+1:end,3)) - PF(T*24+1:end)));
% rmse3 =(mean((table2array(data(T*24+1:end,3)) - PF(T*24+1:end)).^2)).^0.5;
% disp(' ')
% to_display1 = ['Mean Absolute Error for the ARX1 fixed calibration model: ', num2str(mae3)];
% disp(to_display1)
% to_display2 = ['Root Mean Square Error for the ARX1 fixed calibration model: ', num2str(rmse3)];
% disp(to_display2)
% 
% 
% datafinal  = [data mincol hr_24_prev_day];
% index_for_roll_cal = 0;
% T = 731;
% ind_d_entries = 0;
% vec = zeros(7152,1);
% index_for_data_entry = 1;
% for day = 1:298
%     real_train = datafinal(index_for_roll_cal*24+1:(731+index_for_roll_cal)*24,:);
%     for hour=1:24
%         p = table2array(real_train(hour:24:end,"Day-ahead prices"));
%         x = table2array(real_train(hour:24:end,"Day-ahead Load forecasts"));
%         k = table2array(real_train(hour:24:end,'mincol'));
%         z = table2array(real_train(hour:24:end,'hr_24_prev_day'));
%         Dsat = table2array(real_train(hour:24:end, "day")) == 7;
%         Dsun = table2array(real_train(hour:24:end, "day")) == 1;
%         Dmon = table2array(real_train(hour:24:end, "day")) == 2;
%         xx = table2array(datafinal(hour:24:end,"Day-ahead Load forecasts"));
%         DDsat = table2array(datafinal(hour:24:end, "day")) == 7;
%         DDsun = table2array(datafinal(hour:24:end, "day")) == 1;
%         DDmon = table2array(datafinal(hour:24:end, "day")) == 2;        
%         % AR(1) - estimation
%         pcal = p(1:T);
%         xcal = x(1:T);
%         kcal = k(1:T);
%         zcal = z(1:T);
%         Dsatcal = Dsat(1:T);
%         Dsuncal = Dsun(1:T);
%         Dmoncal = Dmon(1:T);
%         yr= pcal(8:end); % for day d, d-1, d-7, load, min24hrbefore, 24th hour from day before, dummies  ...
%         if hour == 24
%             Xr = [ones(T-7,1) pcal(7:end-1) pcal(1:end-7) xcal(8:end) kcal(7:end-1) Dsatcal(8:end) Dsuncal(8:end) Dmoncal(8:end)];
%             X_futr = [1 p(T) p(T-6) xx(T+1+ind_d_entries) k(T) DDsat(T+1+ind_d_entries) DDsun(T+1+ind_d_entries) DDmon(T+1+ind_d_entries)];
%         else
%             Xr = [ones(T-7,1) pcal(7:end-1) pcal(1:end-7) xcal(8:end) kcal(7:end-1) zcal(7:end-1) Dsatcal(8:end) Dsuncal(8:end) Dmoncal(8:end)];
%             X_futr = [1 p(T) p(T-6) xx(T+1+ind_d_entries) k(T) z(T) DDsat(T+1+ind_d_entries) DDsun(T+1+ind_d_entries) DDmon(T+1+ind_d_entries)];
%         end
%         % Regression, i.e., estimate betas
%         beta = regress(yr,Xr);
%         % Make prediction       
%         pf1r = X_futr*beta;
%         vec(index_for_data_entry) = pf1r; 
%         index_for_data_entry = index_for_data_entry + 1;
%     end
%     index_for_roll_cal = index_for_roll_cal + 1;
%     ind_d_entries = ind_d_entries + 1;
% end
% 
% mae4 = mean(abs(table2array(data(T*24+1:end,3)) - vec));
% rmse4 =(mean((table2array(data(T*24+1:end,3)) - vec).^2)).^0.5;
% disp(' ')
% to_display1 = ['Mean Absolute Error for the ARX1 rolling calibration model: ', num2str(mae4)];
% disp(to_display1)
% to_display2 = ['Root Mean Square Error for the ARX1 rolling calibration model: ', num2str(rmse4)];
% disp(to_display2)
% 
% 
% tab4 = [];
% for hour = 1:24
%     p = table2array(data21(hour:24:end,"Day-ahead prices"));
%     g = vec(hour:24:end);
%     tab4(hour,1:3) = [hour mean(abs(p - g)) (mean((p-g).^2)).^0.5];
% end
% tab4 = array2table(tab4);
% tab4.Properties.VariableNames([1 2 3]) = {'Hour' 'MAE','RMSE'};
