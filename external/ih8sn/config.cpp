#include <fstream>
#include "config.h"

config_t load_config() {
    config_t config;

    if (std::ifstream file("/system/etc/ih8sn.conf"); file.good()) {
        std::string line;

        while (std::getline(file, line)) {
            if (line[0] == '#') {
                continue;
            }

            if (const auto separator = line.find('='); separator != std::string::npos) {
                config[line.substr(0, separator)] = line.substr(separator + 1);
            }
        }
    }

    return config;
}
