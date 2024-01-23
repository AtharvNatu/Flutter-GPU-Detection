#include <stdio.h>
#include <stdlib.h>
#include "Main.h"

void run_gpu_script(void)
{
    system("bash get-mac-gpu-info.sh");
}

// int main(void)
// {
//     run_gpu_script();
//     return 0;
// }