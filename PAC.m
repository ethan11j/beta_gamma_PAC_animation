%% PAC Animation Demo — Single Panel Overlay
% 0–10s: PAC (gamma amplitude locked to theta)
% 10–20s: No PAC (gamma independent)
%
% Shows theta + gamma voltage overlay

clear; close all; clc;

%% -----------------------------
% Parameters
% -----------------------------
fs      = 500;      % Hz
T_total = 20;       % seconds
t       = (0:1/fs:T_total-1/fs)';

theta_f = 6;        % Hz
gamma_f = 60;       % Hz

rng(7);

%% -----------------------------
% Build signals
% -----------------------------
theta = sin(2*pi*theta_f*t);
gammaCarrier = sin(2*pi*gamma_f*t);

% No-PAC envelope (slow random modulation)
randSig  = randn(size(t));
randSlow = bandpass(randSig,[0.2 2],fs);
randSlow = (randSlow - min(randSlow)) ./ (max(randSlow)-min(randSlow)+eps);
noPacEnv = 0.2 + 1.2*randSlow;

% PAC envelope (gamma strongest near theta peaks)
pacEnv = 0.2 + 1.2*max(theta,0);

% Stitch envelopes
env = pacEnv;
env(t >= 10) = noPacEnv(t >= 10);

gamma = env .* gammaCarrier;

% Optional small noise
noise = 0.05 * randn(size(t));

% Final signals
thetaSig = theta;
gammaSig = gamma + noise;

%% -----------------------------
% Animation settings
% -----------------------------
winSec = 2;
winN   = round(winSec*fs);
fpsVis = 50;
step   = max(1, round(fs/fpsVis));
minWin = 0.01;

%% -----------------------------
% Figure
% -----------------------------
fig = figure('Color','w','Name','PAC Animation');
ax  = axes(fig);
hold(ax,'on'); grid(ax,'on');

title(ax,'Phase–Amplitude Coupling');
xlabel(ax,'Time (s)');
ylabel(ax,'Voltage');

% Plot handles
hTheta = plot(ax,nan,nan,'k','LineWidth',2);      % theta (black)
hGamma = plot(ax,nan,nan,'r','LineWidth',1);      % gamma (red)

legend({'Theta (slow)','Gamma (fast)'},'Location','northwest');

% Transition line
vline = xline(ax,10,'--','LineWidth',1);

% Label text
txt = text(ax,0.01,0.92,'','Units','normalized', ...
    'FontSize',12,'FontWeight','bold');

%% -----------------------------
% Animate
% -----------------------------
for i = 1:step:length(t)

    startIdx = max(1,i-winN);
    endIdx   = i;

    tt = t(startIdx:endIdx);

    set(hTheta,'XData',tt,'YData',thetaSig(startIdx:endIdx));
    set(hGamma,'XData',tt,'YData',gammaSig(startIdx:endIdx));

    % Safe x-limits
    x0 = tt(1); x1 = tt(end);
    if x1 <= x0 || ~isfinite(x0) || ~isfinite(x1)
        x1 = x0 + minWin;
    end
    xlim(ax,[x0 x1]);

    % Auto y-limits
    yAll = [thetaSig(startIdx:endIdx); gammaSig(startIdx:endIdx)];
    pad  = 0.2*(max(yAll)-min(yAll)+eps);
    ylim(ax,[min(yAll)-pad max(yAll)+pad]);

    % Mode label
    if t(i) < 10
        modeStr = 'PAC: Gamma amplitude locked to theta phase';
    else
        modeStr = 'No PAC: Gamma independent of theta';
    end
    set(txt,'String',sprintf('%s | t = %.2fs',modeStr,t(i)));

    % Show transition line only when visible
    vline.Visible = ternary(x0<=10 && 10<=x1,'on','off');

    drawnow;
    pause(0.001);
end

%% -----------------------------
% Helper
% -----------------------------
function out = ternary(cond,a,b)
if cond, out = a; else, out = b; end
end
