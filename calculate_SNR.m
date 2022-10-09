clear;
close all;

mapName = 'manhattan';
operator = 1; % 1: verizon, 2: att, 3: tmobile
for mapIndex = 0:1
    switch operator
        case 1
            opName = "ver";
        case 2
            opName = "att";
        otherwise
            opName = "tmb";
    end
    
    workspaceName = strcat('results/', mapName, '/map_', int2str(mapIndex), '/', opName, '/workspace.mat');
    % load calculated rays
    load(workspaceName);
    
    pathLoss = zeros(1, rxCount);
    for rx = 1 : rxCount % for each rx
        pathLoss(rx) = 9e9;
        for tx = 1 : txCount % check all txs
            minDirectDis = 9e9; % 
            minReflectedDis = 9e9;
            tempRay = rays(tx, rx);
            tempRay = tempRay{1};
            % check all links
            if (~isempty(tempRay))
                for p = tempRay
                    if p.LineOfSight
                        % shortest LOS path
                        if p.PropagationDistance < minDirectDis
                            minDirectDis = p.PropagationDistance;
                        end
                    else
                        % shortest NLOS path
                        if p.PropagationDistance < minReflectedDis
                            minReflectedDis = p.PropagationDistance;
                        end
                    end
                    
                end
            end
            
            pl1 = -loss_ideal_LOS(minDirectDis);
            pl2 = -loss_ideal_1R(minReflectedDis);
            pl_total = -10 * log10(10^(pl1/10) + 10^(pl2/10));

            if pl_total < pathLoss(rx)
                pathLoss(rx) = pl_total;
            end
        end
    end
    
    idealPathLoss = [rxLati, rxLong, pathLoss'];
    
    %% save all the results
    folderName = strcat('results/', mapName, '/map_', int2str(mapIndex), '/', opName);
    if ~exist(folderName, 'dir')
       mkdir(folderName)
    end
    save(strcat(folderName, '/idealPathLoss'), 'idealPathLoss')
end
