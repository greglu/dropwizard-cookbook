##
# Java
##
default[:java][:install_flavor] = "oracle"
default[:java][:jdk_version] = "7"
default[:java][:oracle] = { "accept_oracle_download_terms" => true }
