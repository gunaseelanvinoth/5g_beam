% checkEnvironment.m
function checkEnvironment()
    disp('Checking Environment...');
    v = ver;
    disp(['MATLAB Version: ', v(1).Release]);
    hasStats = any(strcmp({v.Name}, 'Statistics and Machine Learning Toolbox'));
    if hasStats
        disp('Statistics and Machine Learning Toolbox: Installed');
    else
        disp('Statistics and Machine Learning Toolbox: NOT Installed (Will use fallback)');
    end
end
