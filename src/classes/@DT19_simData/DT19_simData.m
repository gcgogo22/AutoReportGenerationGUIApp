classdef DT19_simData
    % This calss makes the quadrant bar plot on the simulation data
    properties(Access = private)
        four_bar;
        five_bar;
    end
    
    methods
        function obj = DT19_simData
            % This construction funcdtion initialize the raw data
            % This section construct the 5mm fin
            obj.four_bar.junT_5_pnt3_1p1 = 90.5; % junction temperature 5mm fin, 0.3mm AlN, 1.1 lpm flow rate
            obj.four_bar.junT_5_pnt3_1p4 = 86.8;
            obj.four_bar.junT_5_pnt38_1p1 = 92.84;
            obj.four_bar.junT_5_pnt38_1p4 = 89;
            
            obj.five_bar.junT_5_pnt3_1p1 = 81.6; % junction temperature 5mm fin, 0.3mm AlN, 1.1 lpm flow rate
            obj.five_bar.junT_5_pnt3_1p4 = 78.16;
            obj.five_bar.junT_5_pnt38_1p1 = 83.6;
            obj.five_bar.junT_5_pnt38_1p4 = 80.054;
            
            % This section construct the 6mm fin
            obj.four_bar.junT_6_pnt3_1p1 = 90.5; % junction temperature 5mm fin, 0.3mm AlN, 1.1 lpm flow rate
            obj.four_bar.junT_6_pnt3_1p4 = nan;
            obj.four_bar.junT_6_pnt38_1p1 = 92.78;
            obj.four_bar.junT_6_pnt38_1p4 = nan;
            
            obj.five_bar.junT_6_pnt3_1p1 = 81.45; % junction temperature 5mm fin, 0.3mm AlN, 1.1 lpm flow rate
            obj.five_bar.junT_6_pnt3_1p4 = nan;
            obj.five_bar.junT_6_pnt38_1p1 = 83.29;
            obj.five_bar.junT_6_pnt38_1p4 = nan;
        end
        Bar3_PltSimData(obj); % This function makes a 3D quadrant bar plot   
    end
end