#include <fstream>
#include "config.h"

typedef std::map<std::string, std::string> config_map_t;

static std::string get_value_or_empty(const config_map_t &config, const std::string &key) {
    const auto it = config.find(key);
    if (it != config.end()) {
        return it->second;
    }
    return "";
}

#define FIND_AND_REMOVE(s, delimiter, variable_name) \
    std::string variable_name = s.substr(0, s.find(delimiter)); \
    s.erase(0, s.find(delimiter) + delimiter.length());

const std::string Config::get_build_description() const {
    static const std::string kDelimiter = "/";
    static const std::string kDelimiter2 = ":";

    if (build_fingerprint == "") {
        return "";
    }

    std::string build_fingerprint_copy = build_fingerprint;

    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter, brand)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter, product)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter2, device)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter, platform_version)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter, build_id)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter2, build_number)
    FIND_AND_REMOVE(build_fingerprint_copy, kDelimiter, build_variant)
    std::string build_version_tags = build_fingerprint_copy;

    return product + "-" + build_variant + " " + platform_version +
            " " + build_id + " " + build_number + " " + build_version_tags;
}

Config Config::from_file(const std::string config_path) {
    Config config;
    config_map_t config_map;

    if (std::ifstream file(config_path); file.good()) {
        std::string line;

        while (std::getline(file, line)) {
            if (line[0] == '#') {
                continue;
            }

            if (const auto separator = line.find('='); separator != std::string::npos) {
                config_map[line.substr(0, separator)] = line.substr(separator + 1);
            }
        }
    }

    return Config(
        get_value_or_empty(config_map, "BUILD_FINGERPRINT"),
        get_value_or_empty(config_map, "BUILD_SECURITY_PATCH_DATE"),
        get_value_or_empty(config_map, "BUILD_VERSION_RELEASE"),
        get_value_or_empty(config_map, "BUILD_VERSION_RELEASE_OR_CODENAME"),
        get_value_or_empty(config_map, "MANUFACTURER_NAME"),
        get_value_or_empty(config_map, "PRODUCT_NAME")
    );
}
