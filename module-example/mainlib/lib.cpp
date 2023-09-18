#include <iostream>

#if defined(_WIN32) || defined(_WIN64)
#define LIB_EXPORT __declspec(dllexport)
#else
#define LIB_EXPORT
#endif

extern "C"{

void init(void){
    std::cout << "Hola Mundo!\n";
}

}