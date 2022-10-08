clear;
close all;

finalPathLoss = [[1, 2, 5]; [1, 2, 6]; [3, 4, 6]; [3, 2, 6]; [3, 4, 8]];

locs = finalPathLoss(:, 1:2);
[u_locs, index, J] = unique(locs, 'rows');
uFinalPathLoss = finalPathLoss(index, :);

for cnt = 1:length(uFinalPathLoss)
    subLoc = uFinalPathLoss(cnt, 1:2);
    sameValueId = locs(:, 1) == subLoc(1) & locs(:, 2) == subLoc(2);
    subSet = finalPathLoss(sameValueId, :);
    value = max(subSet(:, 3));
    uFinalPathLoss(cnt, 3) = value;
end