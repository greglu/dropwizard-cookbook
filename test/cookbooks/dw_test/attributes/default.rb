##
# Java
##
default[:java][:install_flavor] = "oracle"
default[:java][:jdk_version] = "7"
default[:java][:oracle] = { "accept_oracle_download_terms" => true }


default[:dw_test][:user] = "test"
default[:dw_test][:config] = "/opt/dw_test/config.yml"
