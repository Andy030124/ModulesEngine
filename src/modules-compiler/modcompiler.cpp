#include "modcompiler.hpp"
#include <iostream>
#include <filesystem>
#include <vector>
#include <unordered_map>
#include <ranges>
#include <algorithm>

namespace modcpp{
namespace fs = std::filesystem;

using project_name_t = std::string;
using vec_files_t = std::vector<fs::path>;
using vec_projects_t = std::vector<std::pair<project_name_t, fs::path>>;
using project_tree_t = std::unordered_map<project_name_t, vec_files_t >;

project_tree_t all_projects{};
vec_projects_t compiled_projects{};

std::string getLastPath(fs::path m_dir){
    std::string buff{m_dir.c_str()};
    std::size_t init = buff.rfind('/');
    return buff.substr(init, buff.size());
}

std::vector<fs::path> process_dirs(fs::path initial_dir){
    std::vector<fs::path> files2compile{};

    if( fs::is_directory(initial_dir) ){
        for(auto& $: fs::directory_iterator{initial_dir}){        
            auto tmp = process_dirs($);
            files2compile.insert( files2compile.end(), tmp.begin(), tmp.end() );
        }
    }else if( fs::is_regular_file(initial_dir) || fs::is_character_file(initial_dir) ){
        if( initial_dir.extension() == ".cpp" || initial_dir.extension() == ".c" )
        {
            project_name_t 
            name{getLastPath( initial_dir.parent_path() )},
            fname{initial_dir.c_str()};

            files2compile.emplace_back(name);
            if( all_projects.find(name) != all_projects.end() ){
                all_projects[
                    name
                ].emplace_back(fname);
            }else{
                all_projects.emplace(
                    name,
                    vec_files_t{fname}
                );
            }
        }
    }
    return files2compile;
}

vec_lib_t compile(std::string mpath){
    vec_lib_t result{};
    std::string WORKING_DIR{ fs::absolute(fs::current_path()) };
    std::string MODULES_DIR{ WORKING_DIR + "/modules" };

    if( !fs::exists( MODULES_DIR ) )
        fs::create_directories(MODULES_DIR);

    for(auto& project_name: process_dirs(mpath)){
        auto& project = all_projects.at(project_name);
        std::stringstream cmd{}, out{};
        cmd << "g++ -fPIC -c ";

        for(auto& src: project)
            cmd << src.c_str() << " ";

        out << MODULES_DIR << "/" 
        << project_name.filename().c_str() << ".o";

        cmd << " -o " << out.rdbuf();

        std::cout << cmd.str() << std::endl;
        std::system(cmd.str().c_str());

        compiled_projects.emplace_back(
            project_name.filename().c_str(),
            out.str()
        );
    }
    result.reserve( compiled_projects.size() );
    for(auto& [pname, pfile]: compiled_projects){
        std::stringstream cmd{}, src{};
        src << MODULES_DIR << "/lib" << pname << ".so";

        cmd 
        << "g++ --shared -o " 
        << src.rdbuf() << " "
        << pfile.c_str();
        
        std::cout 
        << "Project '" << pname 
        << "' (" << pfile.c_str() << "):\n" 
        << cmd.str() <<"\n"; 
        std::system(cmd.str().c_str());

        result.emplace_back( src.str() );
        fs::remove(pfile);
    }
    return result;
}

}