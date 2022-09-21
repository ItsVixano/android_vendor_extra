#pragma once

#include <string>
#include <vector>

void property_override(char const prop[], char const value[], bool add = false);
void property_override(const std::vector<std::string> &props, char const value[], bool add = false);
std::vector<std::string> property_list(const std::string &prefix, const std::string &suffix);
