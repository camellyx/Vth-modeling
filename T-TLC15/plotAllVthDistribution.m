function [] = plotAllVthDistribution()

    % call this function in EnduranceSetup_57-467 folder
    block_folders = dir('block_*');
    for i = 1:size(block_folders, 1)
        if ( size(strfind(block_folders(i).name, '_'), 2) == 1 )
            cd(block_folders(i).name);
            folders = dir('cycle_*');
            pecs = arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders);
            arrayfun(@(pec) plotVthDistribution(pec), pecs, 'UniformOutput', false);
            cd('..');
        end
    end

end