##### Penman-Monteith ET Calculation

### Import necessary libraries
import scipy

### Read in necessary data

# Maximum Temperature (C)
tmax = scipy.array([[29,30],[31,30]])

# Minimum Temperature (C)
tmin = scipy.array([[0,-2],[1,0]])

# Dewpoint Temperature (C)
tdew = scipy.array([[22,20],[21,19]])

# Elevation (m)
elev = scipy.array([[200,175],[180,190]])

# Wind Speed (m/s)
u2 = scipy.array([[17,16],[15,16]])

# Latitude (deg)
lat = scipy.array([[50,49],[49,50]])

# Day
day = 15

# Month
month = 4

# Actual Duraction of Sunshine (hours)
n = scipy.array([[10,9],[9,10]])

# Ra


# Rs


# Crop Parameters
# Chapagain & Hoekstra, 1994. Water Footprint of Nations. Vol. II - Appendix VI
# Includes crop coefficients (Kc ini, mid, and end), length of each growing stage (initial, development, middle, and late stage), and planting/greening up date - ORGANIZED BY CLIMATE TYPE (Table 3.2 of same document)


### Conversions
def c_to_k(temp_c):
    temp_k = temp_c + 273.16
    return temp_k

### Equations for remaining variables

# Atmospheric Pressure (P) [kPa] for different altitudes (z) [m]
# Allen et al., 1998 - Table 2.1
def pres(z):
    P = 101.3 * scipy.power( ( ( 293 - 0.0065 * z ) / 293. ) , 5.26 )
    return P

# Latent Heat of Water (Lwater) [MJ/kg] for different temperatures (T) [C]
def latent_heat(T):
    # Polynomial curve fits to Table 2.1. R. R. Rogers; M. K. Yau (1989). A Short Course in Cloud Physics (3rd ed.). Pergamon Press. p. 16. ISBN 0-7506-3215-1. 
    Lwater = ( 2500.8 - 2.36 * T + 0.0016 * scipy.power(T,2) - 0.00006 * scipy.power(T,3) ) / 1000. # [MJ/kg]
    return Lwater

# Psychrometric Constant (gamma) [kPa/C] for different altitudes (z) [m]
# Allen et al., 1998 - Table 2.2
def psych(z,Ltemp=20):
    Cp = 1.013e-3 # specific heat at constant pressure [MJ/kg/C]
    P = pres(z) # atmospheric pressure [kPa]
    E = 0.622 # molecular weight of water vapor / dry air [-]
    if Ltemp: L = latent_heat(Ltemp) # latent heat of vaporization [MJ/kg]
    else: L =  2.45 # approximation for temp = 20 [C]
    gamma = ( Cp * P ) / ( E * L )
    return gamma

# Saturation Vapor Pressure (eoT) [kPa] for different temperatures (T) [C]
# Allen et al., 1998 - Table 2.3
def sat_vap_pres(T):
    eoT = 0.6108 * scipy.exp( ( 17.27 * T ) / ( T + 237.3 ) )
    return eoT

# Slope of Vapor Pressure Curve (Delta) [kPa/C] for different temperatures [C]
# Allen et al., 1998 - Table 2.4
def slope_vap_pres(T):
    delta = 4098 * ( sat_vap_pres(T) ) / scipy.power( (T + 237.3), 2)
    return delta

# Net Radiation at Crop Surface (MJ/m^2/day)
def near_sw_rad(Rs=None):
    # Extraterrestrial Radiation (MJ/m^2/day)
    # Allen et al., 1998 - Table 2.6
    Ra = 12

    # Maximum Duration of Sunshine, N (hours)
    # Allen et al., 1998 - Table 2.7
    N = 14

    # Solar Radiation (MJ/m^2/day)
    # If not available: Rs = (0.25 + 0.5*(n/N))*Ra
    if not Rs: 
        Rs = ( 0.25 + 0.5 * ( n/N ) ) * Ra

    # Near Short-wave Radiation (MJ/m^2/day)
    Rns = 0.77 * Rs

def near_lw_rad(ea,Ra,Tmax,Tmin,Rs):
    # Stefan-Boltzmann Constant [(MJ/K^4)/(m^2/day)]
    sb = 4.903e-9

    # Clear-Sky Radiation (MJ/m^2/day)
    Rso = ( ( 0.75 + 2 * elev ) / 1e5 ) * Ra

    # Near Long-wave Radiation (MJ/m^2/day)
    first = ( ( sb * c_to_k(Tmax) )^4 + ( sb * c_to_k(Tmin) )^4 ) / 2.
    second = ( 0.34 - 0.14 * sqrt(ea) )
    third = ( 1.35 * ( Rs / Rso ) - 0.35)
    Rnl = first * second * third

### Calculate remaining variables

# Mean Temperature (C)
tmean = (tmax+tmin)/2.

# Saturation Vapor Pressure
# es = [(eo(Tmax) + eo(Tmin))]/2
es = ( sat_vap_pres(tmax) + sat_vap_pres(tmin) ) / 2.

# Actual Vapor Pressure
# ea = eo(Tdewpoint)
ea = sat_vap_pres(tdew)

# Net Radiation at Crop Surface (MJ/m^2/day)
Rn = near_sw_rad(Rs) - near_lw_rad(ea,Ra,Tmax,Tmin,Rs)

# Gmonth
# 0.14 * ( T(month) - T(month-1) )
# 0.07 * ( T(month+1) - T(month-1) )
G = 0.14 * ( Tmean - Tmeanprev )

# ET Calculation
def ETo(delta,Rn,G,gamma,T,u2,es,ea):
    ETo = ( 0.408 * delta * ( Rn - G ) + gamma * ( 900 / c_to_k(T) ) * u2 * ( es - ea ) ) / ( delta + gamma * ( 1 + 0.34 * u2 ) )
    return ETo

       
