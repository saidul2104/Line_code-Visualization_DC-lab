function lineCodingVisualization()
    clc; clear; close all;

    while true
        bitSeqPrompt = {'Enter the bit sequence (e.g., [1 0 1 0]):'};
        dlgTitle = 'Input Bit Sequence';
        dims = [1 50];
        defInput = {'[1 0 1 0]'};
        answer = inputdlg(bitSeqPrompt, dlgTitle, dims, defInput);
        
        if isempty(answer)
            break;
        end

        bits = str2num(answer{1});
        bitrate = 1;
        n = 1000; 
        T = length(bits) / bitrate; 
        N = n * length(bits);
        dt = T / N;
        t = 0:dt:T; 
        t(end) = [];
        x = zeros(1, length(t));

        while true
            figure('Name', 'Encoding Schemes', 'Color', 'white', 'Position', [100, 100, 1200, 800]);
            dlgTitle = 'Select Encoding Scheme';
            prompt = 'Select Encoding Scheme:';
            encodingOptions = {'Unipolar', 'Polar (NRZ-L, NRZ-I, RZ, Manchester, Differential Manchester)', 'Bipolar (AMI, Pseudoternary)', 'Multilevel', 'Exit'};
            [encodingSchemeIndex, ~] = listdlg('PromptString', prompt, 'SelectionMode', 'single', 'ListString', encodingOptions, 'Name', dlgTitle);

            if isempty(encodingSchemeIndex) || encodingSchemeIndex == 5
                break; 
            end
            
            switch encodingSchemeIndex
                case 1
                    [x] = unipolarEncoding(bits, n, t, x);
                    subplot(1, 1, 1);
                    plotSignal(t, x, 'Unipolar', 'blue');

                case 2
                    clf;
                    [x] = polarNRZLEncoding(bits, n, t, x);
                    subplot(3, 2, 1);
                    plotSignal(t, x, 'Polar NRZ-L', 'red');
                    [x] = polarNRZIEncoding(bits, n, t, x);
                    subplot(3, 2, 2);
                    plotSignal(t, x, 'Polar NRZ-I', 'blue');

                    [x] = polarRZEncoding(bits, n, t, x);
                    subplot(3, 2, 3);
                    plotSignal(t, x, 'Polar RZ', 'green');

                    [x] = polarManchesterEncoding(bits, n, t, x);
                    subplot(3, 2, 4);
                    plotSignal(t, x, 'Polar Manchester', 'magenta');

                    [x] = differentialManchesterEncoding(bits, n, t, x);
                    subplot(3, 2, 5);
                    plotSignal(t, x, 'Differential Manchester', 'cyan');

                case 3
                    clf;

                    [x] = bipolarAMIEncoding(bits, n, t, x);
                    subplot(2, 1, 1);
                    plotSignal(t, x, 'Bipolar AMI', 'cyan');

                    [x] = bipolarPseudoternaryEncoding(bits, n, t, x);
                    subplot(2, 1, 2);
                    plotSignal(t, x, 'Bipolar Pseudoternary', 'blue');

                case 4
                    clf;
                    [x] = multilevelEncoding(bits, n, t, x);
                    subplot(1, 1, 1);
                    plotSignal(t, x, 'Multilevel Line Coding', 'red');

                otherwise
                    disp('Invalid selection');
            end

            choice = questdlg('Do you want to go back to the main menu?', 'Return to Main Menu', 'Yes', 'No', 'Yes');
            if strcmp(choice, 'No')
                break;
            end

            close all;
        end

        choice = questdlg('Do you want to input a new bit sequence?', 'New Bit Sequence', 'Yes', 'No', 'Yes');
        if strcmp(choice, 'No')
            break;
        end

        close all;
    end

    function plotSignal(t, x, titleStr, color)
        plot(t, x, 'LineWidth', 2, 'Color', color);
        axis([0 t(end) -1.5 1.5]);
        title(titleStr);
        xlabel('Time');
        ylabel('Amplitude');
        grid on;
    end

    function [x] = unipolarEncoding(bits, n, t, x)
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = 0;
            else
                x((i-1)*n+1:i*n) = 1;
            end
        end
    end

    function [x] = polarNRZLEncoding(bits, n, t, x)
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = -1;
            else
                x((i-1)*n+1:i*n) = 1;
            end
        end
    end

    function [x] = polarNRZIEncoding(bits, n, t, x)
        lastbit = 1;
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = lastbit;
            else
                lastbit = -lastbit;
                x((i-1)*n+1:i*n) = lastbit;
            end
        end
    end

    function [x] = polarRZEncoding(bits, n, t, x)
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n-(n/2)) = -1;
                x(i*n-(n/2)+1:i*n) = 0;
            else
                x((i-1)*n+1:i*n-(n/2)) = 1;
                x(i*n-(n/2)+1:i*n) = 0;
            end
        end
    end

    function [x] = polarManchesterEncoding(bits, n, t, x)
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n-(n/2)) = 1;
                x(i*n-(n/2)+1:i*n) = -1;
            else
                x((i-1)*n+1:i*n-(n/2)) = -1;
                x(i*n-(n/2)+1:i*n) = 1;
            end
        end
    end

    function [x] = differentialManchesterEncoding(bits, n, t, x)
        lastbit = -1;
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n-(n/2)) = -lastbit;
                x(i*n-(n/2)+1:i*n) = lastbit;
            else
                lastbit = -lastbit;
                x((i-1)*n+1:i*n-(n/2)) = lastbit;
                x(i*n-(n/2)+1:i*n) = -lastbit;
            end
        end
    end

    function [x] = bipolarAMIEncoding(bits, n, t, x)
        lastbit = -1;
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = 0;
            else
                x((i-1)*n+1:i*n) = lastbit;
                lastbit = -lastbit;
            end
        end
    end

    function [x] = bipolarPseudoternaryEncoding(bits, n, t, x)
        lastbit = -1;
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = lastbit;
                lastbit = -lastbit;
            else
                x((i-1)*n+1:i*n) = 0;
            end
        end
    end

    function [x] = multilevelEncoding(bits, n, t, x)
        level = 3;
        for i = 1:length(bits)
            if bits(i) == 0
                x((i-1)*n+1:i*n) = level;
                level = level - 1;
                if level == 0
                    level = 3;
                end
            else
                x((i-1)*n+1:i*n) = 1;
            end
        end
    end
end
