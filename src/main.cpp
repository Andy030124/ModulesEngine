#include <iostream>
#include "modules-compiler/modcompiler.hpp"
#include <fstream>
#include <filesystem>
#include <dylib.hpp>
#include <algorithm>

namespace fs = std::filesystem;

int main(int argc, char const *argv[]){
    modcpp::vec_lib_t libraries{};
    std::vector<dylib> dlibs{};

    for(int i=1; i < argc; i++){
        const char* $=argv[i];
        auto libs = modcpp::compile($);
        libraries.insert( libraries.end(), libs.begin(), libs.end() );
    }

    if( fs::exists("./modules/lib.cfg") ){
        std::string buff;
        char c;
        std::ifstream file{"./modules/lib.cfg", std::ios::in};
        while( !file.eof() ){
            file >> c;

            if( c != '\n' )
            { buff.push_back(c); }
            else{
                std::cout << "Automatic Added Lib: " << buff.c_str() << "\n";
                if( std::find(libraries.begin(), libraries.end(), buff.c_str()) == libraries.end() )
                    libraries.emplace_back(buff);
                buff.clear();
            }
        }
    }

    for(auto& l: libraries){
        dlibs.emplace_back(
            l.c_str(),
            false
        );
    }

    // initialize all libraries
    for(auto& lib: dlibs)
        lib.get_function<void(void)>("init")();

    std::stringstream out{};
    for(auto& l: libraries)
        out << l.c_str() << "\n";

    {
        std::ofstream file{"./modules/lib.cfg", std::ios::out};
        file << out.rdbuf();
    }

    return 0;
}
