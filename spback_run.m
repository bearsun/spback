function spback_run
% SPBACK_RUN  visuospatial n-back task
%
% The task is adpated from
% Carlson et al. (1998). Distribution of cortical activation during
% visuospatial n-back tasks as revealed by functional magnetic resonance
% imaging. Cerebral Cortex, 8(8), 743–752.
%
% Liwei Sun (sunliwei@ccmu.edu.cn), 1/12/21

% clc;
% AssertOpenGL;
% Priority(1);

global ptb_RootPath %#ok<NUSED>
global ptb_ConfigPath %#ok<NUSED>

subj = input('subject?', 's');
path_data = [pwd, '/data/data-', subj];
outfile = fopen(path_data, 'w');

kspace = KbName('space');
tstim = 0.1;
tisi = 3;
[mseq, mhit, blkodr] = generate_seq;
[nblocks, ntrials] = size(mseq);

idisp = 0;
vrect = [0 0 1024 768];
black = [0 0 0];
white = [255 255 255];
tarsize = 100;
mtrect = [0 0 tarsize tarsize];
fixrect = CenterRectOnPoint([0 0 50 50], vrect(3)/2, vrect(4)/2);

fprintf(outfile, ...
    '%s\t %s\t %s\t %s\t %s\t %s\t %s\n', ...
    'block', 'type', 'trial', 'pos', 'hit', 'keypressed', 'rt');

mpos = [.25 .25  % upperleft
        .5  .25  % uppermiddle
        .75 .25  % upperright
        .25 .5   % midleft
        .75 .5   % midright
        .25 .75  % lowerleft
        .5  .75  % lowermiddle
        .75 .75];% lowerright
    
mpos = mpos * [vrect(3), 0; 0, vrect(4)]; % scaled
    
nhit = 0;
nfa = 0;
crt = 0;
    
pwin = Screen('OpenWindow', idisp, black, vrect);
for iblock = 1:nblocks
    blktype = blkodr(iblock);
    if blktype == 0
        text = 'Please press space if you see a square appear at the indicated location.\nPress space to start.\n';
        targ = mseq(iblock, find(mhit(iblock, :), 1));
        pos = mpos(targ, :);
        frect = CenterRectOnPoint(mtrect, pos(1), pos(2));
        Screen('FillRect', pwin, white, frect);    
    else
        text = ['Please press space if you see the same square as shown ', ...
            num2str(blktype), '-back on the screen.\nPress space to start.\n'];
    end
    DrawFormattedText(pwin, text, 'center', 'center', white);
    Screen('Flip', pwin);
    KbStrokeWait;
    
    Screen('FillOval', pwin, white, fixrect);
    Screen('Flip', pwin);
    tnext = GetSecs + tisi;
    for itrial = 1:ntrials
        kpos = mseq(iblock, itrial);
        pos = mpos(kpos, :);
        frect = CenterRectOnPoint(mtrect, pos(1), pos(2));
        Screen('FillRect', pwin, white, frect);
        Screen('FillOval', pwin, white, fixrect);
        [~, tonset] = Screen('Flip', pwin, tnext); % show
        tcur = tonset;
        tend = tonset + tstim;
        keypressed = 0;
        rt = NaN;
        while isnan(rt) && tcur < tend
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            if keyIsDown && find(keyCode) == kspace
                keypressed = 1;
                rt = timeSecs - tonset;
            end
            tcur = GetSecs;
        end
        Screen('FillOval', pwin, white, fixrect);
        [~, tcur] = Screen('Flip', pwin, tend); % disappear
        tend = tcur + tisi;
        while isnan(rt) && tcur < tend
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            if keyIsDown && find(keyCode) == kspace
                keypressed = 1;
                rt = timeSecs - tonset;
            end
            tcur = GetSecs;
        end
        
        tnext = tend;
        bhit = mhit(iblock,itrial);
        fprintf(outfile, ...
            '%d\t %d\t %d\t %d\t %d\t %d\t %d\n', ...
            iblock, blktype, itrial, kpos, bhit, keypressed, rt);
        
        if keypressed == 1
            if bhit == 1
                nhit = nhit + 1;
                crt = crt + rt;
            else
                nfa = nfa + 1;
            end
        end
    end
    WaitSecs(tend-GetSecs);
end

fclose(outfile);
ntotal = nblocks*ntrials;
npos = sum(sum(mhit));
nneg = ntotal - npos;
dprime = norminv(nhit/npos) - norminv(nfa/nneg);
acc = (nhit+(nneg-nfa))/ntotal;
mrt = crt/nhit;

disp('Accuracy:');
disp(acc);
disp('Reaction time:');
disp(mrt);
disp('d prime:');
disp(dprime);
end