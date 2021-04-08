import math

from random import random as random

NUMBER_OF_PERIODS = 450;

def convolutional_encoder(input_arguments = {
    "clk": [0, 1],
    "rst": [1, 1],
    "i_consume": [0, 0],
    "i_last_data": [0, 0],
    "i_valid": [0, 0],
    "i_data": [0, 0]
}):
    cnt = 'U';
    bit_array = ['U', 'U', 'U', 'U', 'U', 'U', 'U'];    
    output_values = {
        "o_in_ready": [],
        "o_last_data": [],
        "o_valid": [],
        "o_data": [],
        "bit_array": [],
        "cnt": [],
    };

    if not("clk" in input_arguments and "rst" in input_arguments and \
    "i_consume" in input_arguments and "i_last_data" in input_arguments and \
    "i_valid" in input_arguments and "i_data" in input_arguments):
        print("Error: Parameters must be clk, rst, i_consume, i_last_data, " +
        "i_valid and i_data.");
        return output_values;

    number_of_half_cycles = len(input_arguments["clk"]);
    for argument in input_arguments.keys():
        if(number_of_half_cycles>len(input_arguments[argument])):
            number_of_half_cycles = len(input_arguments[argument]);

    resetError = True;

    for it in range(number_of_half_cycles):
        if input_arguments["i_consume"][it] != 0 and \
        input_arguments["i_consume"][it] != 1:
            print("Error: Invalid i_consume!");
            return output_values;
        elif input_arguments["i_last_data"][it] != 0 and \
        input_arguments["i_last_data"][it] != 1:
            print("Error: Invalid i_last_data!");
            return output_values;
        elif input_arguments["i_last_data"][it] != 0 and \
        input_arguments["i_valid"][it] != 1:
            print("Error: Invalid i_valid!");
            return output_values;
        elif input_arguments["i_data"][it] != 0 and \
        input_arguments["i_data"][it] != 1:
            print("Error: Invalid i_data!");
            return output_values;
        elif input_arguments["rst"][it] != 0 and \
        input_arguments["rst"][it] != 1:
            print("Error: Invalid rst!");
            return output_values;
        else:
            if it > 0:
                if input_arguments["clk"][it] == 1 and \
                input_arguments["rst"][it-1] == 1:
                    resetError = False;
            if it < number_of_half_cycles-1:
                if not((input_arguments["clk"][it+1] == 0 and \
                input_arguments["clk"][it] == 1) or \
                (input_arguments["clk"][it+1] == 1 and input_arguments["clk"]\
                [it] == 0)):
                    print("Error: Invalid clock!");
                    return output_values;
    if resetError:
        print("Error: Invalid rst!");
        return output_values;

    for it in range(number_of_half_cycles):
        if it > 0 and input_arguments["clk"][it] == 1:
            if input_arguments["rst"][it-1] == 1:
                cnt = 0;
                bit_array[1:] = [0 for el in range(6)];
            else:
                if cnt != 0:
                    if input_arguments["i_consume"][it-1] == 1:
                        bit_array = bit_array[-1:] + bit_array[:-1];
                        cnt -= 1;
                else:
                    if input_arguments["i_valid"][it-1] == 1 and \
                    input_arguments["i_consume"][it-1] == 1:
                        bit_array = bit_array[-1:] + bit_array[:-1];
                        if input_arguments["i_last_data"][it-1] == 1:
                            cnt = 6;
            
        if cnt == 'U':
            output_values["o_last_data"].append('U');
            bit_array[0] = 'U';
        elif cnt == 0:
            bit_array[0] = input_arguments["i_data"][it];
            output_values["o_last_data"].append(0);
        elif cnt == 1:
            output_values["o_last_data"].append(1);
            bit_array[0] = 0;
        else:
            output_values["o_last_data"].append(0);
            bit_array[0] = 0;

        if input_arguments["rst"][it] == 1:
            output_values["o_in_ready"].append(0);
            output_values["o_valid"].append(0);
        else:
            if cnt == 'U':
                output_values["o_in_ready"].append('U');
                output_values["o_valid"].append('U');  
            elif cnt == 0:
                if input_arguments["i_consume"][it] == 1:
                    output_values["o_in_ready"].append(1);
                else:
                    output_values["o_in_ready"].append(0);
                if input_arguments["i_valid"][it] == 1:
                    output_values["o_valid"].append(1);
                else:
                    output_values["o_valid"].append(0);
            else:
                output_values["o_in_ready"].append(0);
                output_values["o_valid"].append(1);

        if bit_array[0] == 'U' or bit_array[1] == 'U' or bit_array[2] == 'U' \
        or bit_array[3] == 'U' or bit_array[4] == 'U' or bit_array[5] == 'U' \
        or bit_array[6] == 'U':
            output_values["o_data"].append([]);

            if bit_array[0] == 'U' or bit_array[1] == 'U' or bit_array[2] == \
            'U' or bit_array[4] == 'U' or bit_array[6] == 'U':
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                'U');
            else:
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                bit_array[0] ^ bit_array[1] ^ bit_array[2] ^ bit_array[4] ^ \
                bit_array[6]);

            if bit_array[0] == 'U' or bit_array[1] == 'U' or bit_array[2] == \
            'U' or bit_array[3] == 'U' or bit_array[6] == 'U':
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                'U');
            else:
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                bit_array[0] ^ bit_array[1] ^ bit_array[2] ^ bit_array[3] ^ \
                bit_array[6]);

            if bit_array[0] == 'U' or bit_array[2] == 'U' or bit_array[3] == \
            'U' or bit_array[5] == 'U' or bit_array[6] == 'U':
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                'U');
            else:
                output_values["o_data"][len(output_values["o_data"])-1].append(\
                bit_array[0] ^ bit_array[2] ^ bit_array[3] ^ bit_array[5] ^ \
                bit_array[6]);
        else:
            output_values["o_data"].append([bit_array[0] ^ bit_array[1] ^ \
            bit_array[2] ^ bit_array[4] ^ bit_array[6], bit_array[0] ^ \
            bit_array[1] ^ bit_array[2] ^ bit_array[3] ^ bit_array[6], \
            bit_array[0] ^ bit_array[2] ^ bit_array[3] ^ bit_array[5] ^ \
            bit_array[6]]);
        
        output_values["bit_array"].append(str(bit_array));
        output_values["cnt"].append(cnt);

    return output_values;

def generate_inputs(number_of_periods = 0):
    input_values = {
        "clk": [],
        "rst": [],
        "i_consume": [],
        "i_last_data": [],
        "i_valid": [],
        "i_data": []
    };

    if not isinstance(number_of_periods, int) or number_of_periods < 2:
        print("Number of periods should be natural and greater than 1.");
        return input_values;

    input_values["clk"].append(1);
    input_values["clk"].append(0);
    input_values["rst"].append(1);
    input_values["rst"].append(1);
    input_values["i_consume"].append(0);
    input_values["i_consume"].append(0);
    input_values["i_last_data"].append(0);
    input_values["i_last_data"].append(0);
    input_values["i_valid"].append(0);
    input_values["i_valid"].append(0);
    input_values["i_data"].append(0);
    input_values["i_data"].append(0);
    
    for it in range(number_of_periods-1):
        input_values["clk"].append(1);
        input_values["clk"].append(0);
        input_values["rst"].append(0);
        input_values["rst"].append(0);
        #input_values["i_consume"].append(1);
        input_values["i_consume"].append(1 - round(random()/1.8));
        input_values["i_consume"].append(input_values["i_consume"][2*it+2]);
        #if it == number_of_periods-9:
        #    input_values["i_last_data"].append(1);
        #else:
        #    input_values["i_last_data"].append(0);
        input_values["i_last_data"].append(round(random()/1.98));
        input_values["i_last_data"].append(input_values["i_last_data"][2*it+2]);
        #if it <= number_of_periods-9:
        #    input_values["i_valid"].append(1);
        #else:
        #    input_values["i_valid"].append(0);
        input_values["i_valid"].append(1 - round(random()/1.8));
        input_values["i_valid"].append(input_values["i_valid"][2*it+2]);
        #input_values["i_data"].append(1);
        input_values["i_data"].append(round(random()));
        input_values["i_data"].append(input_values["i_data"][2*it+2]);

    return input_values;

def forceOpenFile(fileName = "dummy.txt"):
    while True:
        try:
            newFile = open(fileName, "w");
        except IOError as error:
            print("Could not open the file due to:");
            print(error);
            print("Retrying...");
        else:
            break;
    print("File " + fileName + " has been successfully opened.");
    return newFile;

input_data = generate_inputs(NUMBER_OF_PERIODS);
output_data = convolutional_encoder(input_data);

#try:
#    outputFile = open("convolutional.csv","r");
#except IOError:
#    print("File convolutional.csv does not exist. Trying to open it.");
#else:
#    while not outputFile.closed:
#        outputFile.close();
#    print("File convolutional.csv already exists.");
#    answer = input("Overwrite it? [Y/n]");
#    if answer != "Y" and answer != "y":
#        quit();


inputFile = forceOpenFile("convolutional_input.txt");
outputFile = forceOpenFile("convolutional_output.txt");
logFile = forceOpenFile("convolutional_log.txt");

try:
    
    logFile.write(" clk , rst , i_consume , i_last_data , i_valid ," +
    " i_data , o_in_ready , o_last_data , o_valid , o_data \n");

    for it in range(2*NUMBER_OF_PERIODS):
        logFile.write("  " + str(input_data["clk"][it]) + "  ,  " + \
        str(input_data["rst"][it]) + "  ,     " + \
        str(input_data["i_consume"][it]) + "     ,      " + \
        str(input_data["i_last_data"][it]) + "      ,    " + \
        str(input_data["i_valid"][it]) + "    ,   " + \
        str(input_data["i_data"][it]) + "    ,     " + \
        str(output_data["o_in_ready"][it]) + "      ,      " + \
        str(output_data["o_last_data"][it]) + "      ,    " + \
        str(output_data["o_valid"][it]) + "    ,  " + \
        str(output_data["o_data"][it][2]) + " " + \
        str(output_data["o_data"][it][1]) + " " + \
        str(output_data["o_data"][it][0]) + "  " + \
        str(output_data["bit_array"][it]) + "  " + \
        str(output_data["cnt"][it]) + " \n");

        outputFile.write(" " + str(output_data["o_in_ready"][it]) + " " + \
        str(output_data["o_last_data"][it]) + " " + \
        str(output_data["o_valid"][it]) + " " + \
        str(output_data["o_data"][it][2]) + " " + \
        str(output_data["o_data"][it][1]) + " " + \
        str(output_data["o_data"][it][0]) + " \n");

        inputFile.write(" " + str(input_data["clk"][it]) + " " + \
        str(input_data["rst"][it]) + " " + \
        str(input_data["i_consume"][it]) + " " + \
        str(input_data["i_last_data"][it]) + " " + \
        str(input_data["i_valid"][it]) + " " + \
        str(input_data["i_data"][it]) + " \n");

finally:
    while not inputFile.closed:
        inputFile.close();
    while not outputFile.closed:
        outputFile.close();
    while not logFile.closed:
        logFile.close();

    print("File convolutional_input.txt closed.");
    print("File convolutional_output.txt closed.");
    print("File convolutional_log.txt closed.");

