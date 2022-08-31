% calculates range based on P0/W0 values from constraint analysis
% Quynh-Anh Duong
% Created: 31 August 2022

clear all; close all; clc;

%% known data
P_shaft = 6192e3; %W
B_power_rate = 1.33e3; %W/kg
mB = 1419; %kg
eta_pr = 0.8; %prop efficiency

% de-rating values at [takeoff, climb, cruise]
de_rate = [1 0.7225 0.445];

% battery charging
B_charge_rate = 1.666e3; %W/kg

% fuel
PSFC = 8.5e-8; %kg/Ws
mf = 3614; %kg

% take off weight
g = 9.8065; %m/s2
MTOW = 25650 - 6300; %kg
W0 = MTOW*g;

% constraint factors P0/W0 at [takeoff, climb, cruise]
P0_W0 = [33 4.5 27];

%% takeoff
t_to = 26; %s

% --- Power and fuel values ---
P_to = P_shaft*eta_pr;
P_to_req = P0_W0(1)*W0*de_rate(1)*eta_pr;

Prop_to = 0.9*P_to_req; B_to = 0.1*P_to_req;

mf_to = Prop_to*PSFC*t_to; %kg

% --- STOL ---
R_to = 1000; %m
R_to_nm = R_to/1852; %nm

%% climb
t_climb = 490; %s

% --- Power and fuel values ---
P_c_req = P0_W0(2)*de_rate(2)*eta_pr*W0;
mf_c = P_c_req*PSFC*t_climb; %kg

% --- Range values ---
% climb
V_climb = 69.4678; %m/s
h_climb = (25000-35)/3.281; %m

% range
d_climb = V_climb*t_climb;
theta_climb = sind(h_climb/d_climb); %deg
R_climb = d_climb*tand(theta_climb); % m
R_climb_nm = R_climb/1852; %nm

%% cruise
% V = 300KTAS
% h = 25000 ft

% --- Power and fuel values ---
P_cruise_req =  P0_W0(3)*de_rate(3)*eta_pr*W0;
P_cruise_avail = P_shaft*de_rate(3)*eta_pr;
P_recharge = P_cruise_avail - P_cruise_req;

% energy from battery consumed
EB_used = B_to*t_to; %J

% max recharge rate is the remaining power available
charge_rate = P_recharge;%linspace(1,P_recharge,100); %kW = J/s
t_charge = EB_used./charge_rate; %s

% when charging we fly at max available power
mf_charge = PSFC*P_cruise_avail*t_charge; % kg

% fuel mass left after charging battery
mf_cruise = mf - mf_to - mf_c - mf_charge - 0.15*mf; %kg - save 15% for landing and 5% contingency

% divide the available mass by the mass flow rate to get time
t_cruise = mf_cruise/(P_cruise_req*PSFC); %s

% --- Range values ---
V_cruise = 300/1.944; %m/s
R_cruise = V_cruise*t_cruise; %m
R_cruise_nm = R_cruise/1852; %nm

%% descent
% from skybrary: 'The general formula used for calculating the distance
% required for descent is ‘3 times the height’, where the ‘height’ used 
% is in multiples of thousands of feet.'
% https://www.skybrary.aero/descend-approach-and-landing

h_descent = 25000-50; %ft, with 50ft clearance as per slide 42 note set 13
R_descent = 3*h_descent; %ft
R_descent_nm = R_descent/6076; %nm

% values froms lide 42 note set 13
a_ = 0.3;
h_land = 15.24; %m (convert 50ft)
gamma_app = 3; %deg
W_S = 9.8065*(MTOW - 0.85*mf)/84;
CL_max_app = 1.36; % historical value - need to change based on what Will gets
rho = 1.225; % kg/m3

% range
R_land = h_land/tand(gamma_app) + 1.69*(W_S/(rho*a_*CL_max_app));
R_land_nm = R_land/1852; %nm

%% total range
R = R_to_nm + R_climb_nm + R_cruise_nm + R_land_nm;