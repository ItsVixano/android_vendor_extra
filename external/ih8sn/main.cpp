#include "config.h"
#include "properties.h"

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

int main(int argc, char *argv[]) {
    if (__system_properties_init()) {
        return -1;
    }

    if (argc != 2) {
        return -1;
    }

    const auto is_init_stage = strcmp(argv[1], "init") == 0;
    const auto is_boot_completed_stage = strcmp(argv[1], "boot_completed") == 0;

    const auto config = load_config();
    const auto build_fingerprint = config.find("BUILD_FINGERPRINT");
    const auto build_security_patch_date = config.find("BUILD_SECURITY_PATCH_DATE");
    const auto build_version_release = config.find("BUILD_VERSION_RELEASE");
    const auto build_version_release_or_codename = config.find("BUILD_VERSION_RELEASE_OR_CODENAME");
    const auto manufacturer_name = config.find("MANUFACTURER_NAME");
    const auto product_name = config.find("PRODUCT_NAME");

    if (is_init_stage && build_fingerprint != config.end()) {
        property_override(property_list("ro.", "build.fingerprint"),
                build_fingerprint->second.c_str());
        property_override("ro.build.description",
                fingerprint_to_description(build_fingerprint->second).c_str());
    }

    if (is_boot_completed_stage && build_version_release != config.end()) {
        property_override(property_list("ro.", "build.version.release"),
                build_version_release->second.c_str());
    }

    if (is_boot_completed_stage && build_version_release_or_codename != config.end()) {
        property_override(property_list("ro.", "build.version.release_or_codename"),
                build_version_release_or_codename->second.c_str());
    }

    if (is_boot_completed_stage && build_security_patch_date != config.end()) {
        property_override("ro.build.version.security_patch",
                build_security_patch_date->second.c_str());
    }

    if (is_init_stage && manufacturer_name != config.end()) {
        property_override(property_list("ro.product.", "manufacturer"),
                manufacturer_name->second.c_str());
    }

    if (is_init_stage && product_name != config.end()) {
        property_override(property_list("ro.product.", "name"), product_name->second.c_str());
    }

    if (is_init_stage) {
        property_override("ro.debuggable", "0");
        property_override(property_list("ro.", "build.tags"), "release-keys");
        property_override(property_list("ro.", "build.type"), "user");
    }

    if (is_boot_completed_stage) {
        property_override("ro.boot.verifiedbootstate", "green");
    }

    return 0;
}
