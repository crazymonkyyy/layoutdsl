//chatgpt attempt, popen was 2001, d uses c99 or something

//import std.stdio : writeln;
//import core.stdc.stdio : FILE, fgets, pclose, popen;
//import core.stdc.string : strlen, strncpy;
//
import std;
import core.stdc.stdio;
enum BUFFER_SIZE = 1024;

int execute_command(const(char)* command, char[] output) {
    FILE* fp = popen(command, "r");
    if (fp is null) {
        writeln("Error opening pipe to command: ", command);
        return -1;
    }

    size_t total_output_len = 0;
    char[BUFFER_SIZE] buffer;
    while (fgets(buffer.ptr, BUFFER_SIZE, fp) !is null) {
        size_t buffer_len = strlen(buffer.ptr);
        if (total_output_len + buffer_len >= output.length) {
            writeln("Output buffer too small");
            pclose(fp);
            return -1;
        }
        strncpy(output.ptr + total_output_len, buffer.ptr, buffer_len);
        total_output_len += buffer_len;
    }

    int status = pclose(fp);
    if (status == -1) {
        writeln("Error closing pipe to command: ", command);
        return -1;
    }

    return 0;
}

import std.stdio : writeln;

void main() {
    char[BUFFER_SIZE] output;
    int result = execute_command("echo '1 + 2' | bc", output);
    if (result != 0) {
        // Handle error
    } else {
        writeln("Result: ", output.ptr);
    }
}
