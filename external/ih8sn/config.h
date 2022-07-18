#pragma once

#include <map>

typedef std::map<std::string, std::string> config_t;

config_t load_config();
