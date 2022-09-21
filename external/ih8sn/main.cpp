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

    const auto config = Config::from_file("/system/etc/ih8sn.conf");

    if (is_init_stage && config.build_fingerprint != "") {
        property_override(property_list("ro.", "build.fingerprint"),
                config.build_fingerprint.c_str());
        property_override("ro.build.description", config.get_build_description().c_str());
    }

    if (is_boot_completed_stage && config.build_version_release != "") {
        property_override(property_list("ro.", "build.version.release"),
                config.build_version_release.c_str());
    }

    if (is_boot_completed_stage && config.build_version_release_or_codename != "") {
        property_override(property_list("ro.", "build.version.release_or_codename"),
                config.build_version_release_or_codename.c_str());
    }

    if (is_boot_completed_stage && config.build_security_patch_date != "") {
        property_override("ro.build.version.security_patch",
                config.build_security_patch_date.c_str());
    }

    if (is_init_stage && config.manufacturer_name != "") {
        property_override(property_list("ro.product.", "manufacturer"),
                config.manufacturer_name.c_str());
    }

    if (is_init_stage && config.product_name != "") {
        property_override(property_list("ro.product.", "name"), config.product_name.c_str());
    }

    if (is_init_stage) {
        property_override("ro.debuggable", "0");
        property_override(property_list("ro.", "build.tags"), "release-keys");
        property_override(property_list("ro.", "build.type"), "user");
    }

    if (is_boot_completed_stage) {
        property_override("ro.boot.flash.locked", "1");
        property_override("ro.boot.vbmeta.device_state", "locked");
        property_override("ro.boot.verifiedbootstate", "green");
        property_override("ro.boot.veritymode", "enforcing");
        property_override("ro.boot.warranty_bit", "0");
        property_override("ro.warranty_bit", "0");
    }

    return 0;
}
