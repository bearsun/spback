function [mseq, mhit, blockorder] = generate_seq
%GENERATE_SEQ Generate sequence for 0-back, 1-back, 2-back
% Work together with spback_run
% return: 
%   mseq: a sequence of position indices of stimuli
%   mhit: a boolen sequence of repeat/target/response
% Liwei Sun, 1/13/21
rng('Shuffle');

vlocs = 1:8;
nblocks = 6;
ntrials = 32;
ntars = 8;
blockorder = [0, 1, 2, 2, 1, 0];
seeds = randi(100, [nblocks,1]);

mseq = NaN(nblocks, ntrials);
mhit = NaN(nblocks, ntrials);

for iblock = 1:nblocks
    if blockorder(iblock) == 0
        [mseq(iblock, :), mhit(iblock, :)] = zero_back(ntrials, ntars, vlocs, seeds(iblock));
    elseif blockorder(iblock) == 1
        [mseq(iblock, :), mhit(iblock, :)] = one_back(ntrials, ntars, vlocs, seeds(iblock));
    elseif blockorder(iblock) == 2
        [mseq(iblock, :), mhit(iblock, :)] = two_back(ntrials, ntars, vlocs, seeds(iblock));
    end
end

    function [seq, seqhit] = two_back(ntrials, ntars, vlocs, seed)
        % 2-back
        rng(seed);
        seqhit = logical([0; 0;  Shuffle([zeros(ntrials-ntars-2, 1); ones(ntars, 1)])]);
        
        seq = BalanceTrials(ntrials, 1, vlocs);
        seq = seq(1:ntrials);
        seq = update_seq(seq, seqhit, ntrials, 2, vlocs);
    end

    function [seq, seqhit] = one_back(ntrials, ntars, vlocs, seed)
        % 1-back
        rng(seed);
        seqhit = logical([0; Shuffle([zeros(ntrials-ntars-1, 1); ones(ntars, 1)])]);
        
        seq = BalanceTrials(ntrials, 1, vlocs);
        seq = seq(1:ntrials);
        seq = update_seq(seq, seqhit, ntrials, 1, vlocs);
    end

    function [seq, seqhit] = zero_back(ntrials, ntars, vlocs, seed)
        % 0-back
        rng(seed);
        seqhit = logical(Shuffle([zeros(ntrials-ntars, 1); ones(ntars, 1)]));
        targ = randi(max(vlocs));
        locs = vlocs(vlocs ~= targ);
        seq = BalanceTrials(ntrials, 1, locs);
        seq = seq(1:ntrials);
        seq(seqhit) = targ;
    end

    function seq = update_seq(seq, hit, ntrials, nback, vlocs)
        for itrial = 1:ntrials
            if hit(itrial)
                seq(itrial) =  seq(itrial-nback);
            else
                if itrial-nback > 0 && seq(itrial) == seq(itrial-nback)
                    cur = seq(itrial);
                    locs = vlocs(vlocs ~= cur);
                    seq(itrial) = locs(randi(numel(locs)));
                end
            end
        end
    end
end

