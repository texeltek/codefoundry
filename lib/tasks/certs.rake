require 'certificate_authority'

desc "Common tasks related to x509 certificates for CodeFoundry"
namespace :certs do
  desc "Generate a cert, public key, and private key for a sample Certificate Authority (CA)"
  task :sample_ca do
    
    cn = "https://codefoundry:8443"
    cn = ENV['DOMAIN'] unless ENV['DOMAIN'].nil?
    
    puts "Generating sample CA"
    puts "CA common_name = #{cn}"
    
    root = CertificateAuthority::Certificate.new
    root.subject.common_name = cn
    root.serial_number.number = 1
    root.key_material.generate_key
    root.signing_entity = true
    root.valid?
    root.sign!
    
    puts "Writing certificate to #{Rails.root}/config/sample/ca_sample.cert.pem"
    File.open("#{Rails.root}/config/sample/ca_sample.cert.pem", "w") {|f| f.write(root.to_pem) }
    
    puts "Writing public key to  #{Rails.root}/config/sample/ca_sample.pubkey.pem"
    File.open("#{Rails.root}/config/sample/ca_sample.pubkey.pem", "w") {|f| f.write(root.key_material.public_key.to_pem) }
    
    puts "Writing private key to #{Rails.root}/config/sample/ca_sample.key.pem"
    File.open("#{Rails.root}/config/sample/ca_sample.key.pem", "w") {|f| f.write(root.key_material.private_key.to_pem) }
  end
end
