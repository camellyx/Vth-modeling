function [] = fitAllGaussMix()

    % call this function in EnduranceSetup_57-467 folder
    block_folders = dir('block_*');
    for i = 1:size(block_folders, 1)
        if ( size(strfind(block_folders(i).name, '_'), 2) == 1 )
            disp(block_folders(i).name);
            cd(block_folders(i).name);
            folders = dir('cycle_*');
            pecs = arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders);
            for k = 1:size(pecs, 1)
                vths = readBlock('cycle_%04d', 'cycle_%04d/%04d-%03d-VTMPB26-Reads.dat', 'cycle_%04d/Write.dat', pecs(k), pecs(k));
                fitGaussMix('cycle_%04d', pecs(k), vths);
            end
            cd('..');
        end
        if ( size(strfind(block_folders(i).name, '_Retention'), 2) == 1 )
            disp(block_folders(i).name);
            cd(block_folders(i).name);
            ret_time = ['1m'; '3m'; '6m'; '1y'];
            for j = 1:size(ret_time, 1)
                cd(ret_time(j,:));
                folders = dir('cycle_*');
                pecs = arrayfun(@(f) sscanf(f.name, 'cycle_%d'), folders);
                for k = 1:size(pecs, 1)
                    vths = readBlock('cycle_%04d', 'cycle_%04d/%04d-%03d-VTMPB26-Reads.dat', 'cycle_%04d/Write.dat', pecs(k), pecs(k));
                    fitGaussMix('cycle_%04d', pecs(k), vths);
                end
                cd('..');
            end
            cd('..');
        end
        if ( size(strfind(block_folders(i).name, '_Rd_Disturb'), 2) == 1 )
            disp(block_folders(i).name);
            cd(block_folders(i).name);
            folders = dir('block_read_cycle_*');
            pecs = arrayfun(@(f) sscanf(f.name, 'block_read_cycle_%d'), folders);
            for k = 1:size(pecs, 1)
                vths = readBlock('block_read_cycle_%04d', 'block_read_cycle_%04d/%04d-%03d-VT-Reads.dat', 'block_read_cycle_%04d/../Write.dat', pecs(k), pecs(k)/5);
                fitGaussMix('block_read_cycle_%04d', pecs(k), vths);
            end
            cd('..');
        end
    end

end