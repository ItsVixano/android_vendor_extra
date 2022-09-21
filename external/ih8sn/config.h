#pragma once

#include <map>
#include <string>

struct Config {
    Config(
            const std::string build_fingerprint = "",
            const std::string build_security_patch_date = "",
            const std::string build_version_release = "",
            const std::string build_version_release_or_codename = "",
            const std::string manufacturer_name = "",
            const std::string product_name = ""
    ) : build_fingerprint(build_fingerprint),
        build_security_patch_date(build_security_patch_date),
        build_version_release(build_version_release),
        build_version_release_or_codename(build_version_release_or_codename),
        manufacturer_name(manufacturer_name),
        product_name(product_name) {}

    const std::string build_fingerprint;
    const std::string build_security_patch_date;
    const std::string build_version_release;
    const std::string build_version_release_or_codename;
    const std::string manufacturer_name;
    const std::string product_name;

    const std::string get_build_description() const;

    static Config from_file(const std::string config_path);
};
