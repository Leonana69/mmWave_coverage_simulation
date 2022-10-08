clear;
close all;
%% filter by mcc
index = int32([310, 311, 312, 313, 316]);

for x = index
    in_file_name = "data/" + int2str(x) + ".csv";
    out_file_name = "data/" + int2str(x) + ".txt";
    
    data = readtable(in_file_name);
    LTE_index = (data.Var1 == "LTE");
    filtered_data = data(LTE_index, 2:14);
    writetable(filtered_data, out_file_name);
end

%% filter by operator
operator = 3; % verizon: 1, att: 2, tmobile: 3
mcc_mnc_ver = [[310, 4]; [310, 5]; [310, 6]; [310, 12]; [310, 5]; [311, 12]; [311, 480]; [310, 13]; [310, 590]; [310, 591]; [310, 592]; [310, 593]; [310, 594]; [310, 595]; [310, 596]; [310, 597]; [310, 598]; [310, 599]; [310, 820]; [310, 890]; [310, 891]; [310, 892]; [310, 893];[310, 894];[310, 895];[310, 896];[310, 897];[310, 898];[310, 899];[310, 910];[311, 110];[312, 770]];
mcc_mnc_att = [[310, 30]; [310, 70]; [310, 80]; [310, 90]; [310, 150]; [310, 170]; [310, 410]; [310, 680]; [310, 950]; [311, 70]; [311, 90]; [312, 670]; [313, 100]; [310, 670]; [311, 190];[312, 680];[313, 30];[313, 110];[313, 120];[313, 130];[313, 140];[313, 150];[313, 160];[313, 170];[313, 180];[313, 190];[313, 210]];
mcc_mnc_tmb = [[310, 120]; [310, 160]; [310, 260]; [310, 490]; [311, 490]; [311, 882]; [312, 530]; [310, 530]; [310, 770]; [311, 880]; [312, 190];[312, 250]];

mcc_index = int32([310, 311, 312, 313, 316]);

cell_locations = array2table(zeros(0,13), 'VariableNames',{'mcc', 'mnc', 'lac', 'cid', 'unit', 'lon', 'lat',  'range', 'samples', 'changeable', 'create', 'update', 'ave_sig'});

for x = mcc_index
    if operator == 1
        mcc_mnc_temp = mcc_mnc_ver;
    elseif operator == 2
        mcc_mnc_temp = mcc_mnc_att;
    else
        mcc_mnc_temp = mcc_mnc_tmb;
    end
    mcc_index = mcc_mnc_temp(mcc_mnc_temp(:, 1) == x, 2);

    data = readtable("data\" + int2str(x) + ".txt");
    data.Properties.VariableNames = {'mcc', 'mnc', 'lac', 'cid', 'unit', 'lon', 'lat',  'range', 'samples', 'changeable', 'create', 'update', 'ave_sig'};
    cell_locations = [cell_locations; data(ismember(data.mnc, mcc_index), :)];
end

if operator == 1
    out_file_name = "data\ver.txt";
elseif operator == 2
    out_file_name = "data\att.txt";
else
    out_file_name = "data\tmb.txt";
end

writetable(cell_locations, out_file_name);
