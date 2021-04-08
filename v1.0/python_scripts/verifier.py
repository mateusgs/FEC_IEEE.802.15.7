#from convolutional import forceOpenFile

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

def readFileContent(fileName = "dummy.txt"):
    try:
        openedFile = open(fileName, "r");
    except IOError as error:
        print("Could not open the file due to:");
        print(error);
    else:
        fileContent = openedFile.readlines();
        while not openedFile.closed:
            openedFile.close();
        return fileContent;


dutOutput = readFileContent("convolutional_output_dut.txt");
expectedOutput = readFileContent("convolutional_output.txt");
logFile = forceOpenFile("error_log.txt");

try:
    filesLength = min(len(dutOutput),len(expectedOutput));
    for line in range(filesLength):
        if dutOutput[line] != expectedOutput[line]:
            logFile.write("Line " + str(line) + " has different outputs.\n");
            logFile.write("\tExpected output:" + expectedOutput[line]);
            logFile.write("\tActual output:" + dutOutput[line] + "\n");
    if len(dutOutput) != len(expectedOutput):
        logFile.write("Warning: files have different lengths.\n\n")

finally:
    for line in dutOutput:
        logFile.close();

    print("File error_log.txt closed.");
