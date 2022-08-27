function [x1, x2, dis]= area_per(x,percent)
%AREA_PER calculate the starting and ending points symmetric around the
%beam center and return the distance. 
%percent is the percentage of the total area.

% x = 1:100;
% percent = 0.9; % calculate 90%
x(x<0.04) =0; % set the threshold to clean up the noise
x_area = trapz(x)*percent;

x_len = length(x);
x_cor = 0:x_len-1; 
x_cen = sum(x.*x_cor)./sum(x); % calculate x centroid

x1 = floor(x_cen)-1; % index of <x_cen
x2 = ceil(x_cen)+1; % index of >x_cen

try
chk = true;
while chk
    if trapz(x(x1:x2))/x_area >=1 
        chk = false;
    else
        if x1 ~= 0
            x1 = x1 -1;
        end
        if x2 ~= x_len-1
            x2 = x2 +1;
        end
    end

end

dis = x2 -x1; 
catch
end


