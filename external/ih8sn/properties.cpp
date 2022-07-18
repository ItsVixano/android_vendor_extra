#include "properties.h"

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

void property_override(char const prop[], char const value[], bool add) {
    auto pi = (prop_info *) __system_property_find(prop);

    if (pi != nullptr) {
        __system_property_update(pi, value, strlen(value));
    } else if (add) {
        __system_property_add(prop, strlen(prop), value, strlen(value));
    }
}

void property_override(const std::vector<std::string> &props, char const value[], bool add) {
    for (const auto &prop : props) {
        property_override(prop.c_str(), value, add);
    }
}

std::vector<std::string> property_list(const std::string &prefix, const std::string &suffix) {
    std::vector<std::string> props;

    for (const std::string &part : {
        "",
        "bootimage.",
        "odm_dlkm.",
        "odm.",
        "oem.",
        "product.",
        "system_ext.",
        "system.",
        "vendor_dlkm.",
        "vendor.",
    }) {
        props.emplace_back(prefix + part + suffix);
    }

    return props;
}

#define FIND_AND_REMOVE(s, delimiter, variable_name) \
    std::string variable_name = s.substr(0, s.find(delimiter)); \
    s.erase(0, s.find(delimiter) + delimiter.length());

const std::string fingerprint_to_description(const std::string &fingerprint) {
    const std::string delimiter = "/";
    const std::string delimiter2 = ":";

    std::string build_fingerprint_copy = fingerprint;

    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, brand)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, product)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter2, device)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, platform_version)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, build_id)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter2, build_number)
    FIND_AND_REMOVE(build_fingerprint_copy, delimiter, build_variant)
    std::string build_version_tags = build_fingerprint_copy;

    const std::string description = product + "-" + build_variant + " " + platform_version +
            " " + build_id + " " + build_number + " " + build_version_tags;

    return description;
}
