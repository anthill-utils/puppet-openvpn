# Fact: openvpn_<server>_<clientname>_ca,
#       openvpn_<server>_<clientname>_crt,
#       openvpn_<server>_<clientname>_key
#
# Purpose:
#   Collect clients' OpenVPN generated keys (presumably for exported resources).
#

require 'etc'
require 'facter'

module Facter::OpenvpnKeys

  def self.add_facts

    if File.directory?("/etc/openvpn")

        # iterate over /etc/openvpn
        Dir.foreach("/etc/openvpn") do |server_name|
            server_dir = File.join("/etc/openvpn", server_name)
            next if server_name == '.' or server_name == '..' or File.file?(server_dir)
            server_full_dir = File.join(server_dir, "export-configs")
            if File.directory?(server_full_dir)

                # iterate over /etc/openvpn/<server>/export-configs
                Dir.foreach(server_full_dir) do |client_name|
                    client_full_dir = File.join(server_full_dir, client_name)
                    next if client_name == '.' or client_name == '..' or File.file?(client_full_dir)

                    client_ca_dir = File.join(client_full_dir, "ca.crt")
                    client_key_dir = File.join(client_full_dir, client_name + ".key")
                    client_crt_dir = File.join(client_full_dir, client_name + ".crt")

                    if File.file?(client_ca_dir)
                        Facter.add("openvpn_" + server_name + "_" + client_name + "_ca") do
                          setcode { File.read(client_ca_dir) }
                        end
                    end

                    if File.file?(client_crt_dir)
                        Facter.add("openvpn_" + server_name + "_" + client_name + "_crt") do
                          setcode { File.read(client_crt_dir) }
                        end
                    end

                    if File.file?(client_key_dir)
                        Facter.add("openvpn_" + server_name + "_" + client_name + "_key") do
                          setcode { File.read(client_key_dir) }
                        end
                    end

                end
            end
        end

    end
  end
end

Facter::OpenvpnKeys.add_facts
