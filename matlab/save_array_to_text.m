function save_array_to_text(data, filename)
    %---------------------------------------------------------------------%
    %Function to save 1-D array into a text file with each element in a single line%

    %Ensuring 1-D array is a column vector
    if isrow(data)
        data = data';
    end

    %Saving the array to the desired text file
    writematrix(data, filename);
end