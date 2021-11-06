function [fpr, acc, fscore] = evaluateMetrics(gt, road)
%EVALUATE Summary of this function goes here
%   Detailed explanation goes here
    tpMat = gt & road;
    tnMat = ~gt & ~road;
    fpMat = ~gt & road;
    fnMat = gt & ~road;
    
    tp = sum(tpMat(:) == 1);
    tn = sum(tnMat(:) == 1);
    fp = sum(fpMat(:) == 1);
    fn = sum(fnMat(:) == 1);
    
    fpr = fp / (fp + tn);
    acc = (tp + tn) / (tp + tn + fp + fn);
    pre = tp / (tp + fp);
    rec = tp / (tp + fn);
    fscore = 2 * ((pre * rec) / (pre + rec));
end

