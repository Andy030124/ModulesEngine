#pragma once
#include <string>
#include <vector>

namespace modcpp{
using vec_lib_t = std::vector<std::string>;
vec_lib_t compile(std::string mpath);
}