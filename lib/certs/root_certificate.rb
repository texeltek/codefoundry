require 'certificate_authority'

module CodeFoundryCertificates
  class RootCertificate
  
    attr_accessor :root_ca
    attr_accessor :root_dn
  
    attr_accessor :public_key
    attr_accessor :private_key
  
    attr_accessor :public_key_file
    attr_accessor :private_key_file
  
    attr_accessor :passphrase
  
    attr_accessor :dn
  
    def initialize( filename = "#{Rails.root}/config/ca.yml" )
      load_ca_from_yaml( filename )
      load_dn_from_yaml( filename )
    end
  
    def root
      @root_ca ||= load_ca_from_yaml
    end
  
    def load_ca_from_yaml( filename="#{Rails.root}/config/ca.yml" )
      raise "CA configuration file {filename} does not exist." unless File.exists?( filename )
      
      yaml = YAML::load( File.open(filename) )['ca']
    
      ca = CertificateAuthority::Certificate.new
    
      ca.subject.common_name         = yaml['common_name']
      ca.subject.locality            = yaml['locality']
      ca.subject.state               = yaml['state']
      ca.subject.country             = yaml['country']
      ca.subject.organization        = yaml['organization']
      ca.subject.organizational_unit = yaml['organizational_unit']
      ca.serial_number.number        = yaml['serial_number']
      ca.signing_entity              = yaml['signing_entity'] || true

      key_material = CertificateAuthority::MemoryKeyMaterial.new

      @root_dn = yaml['dn']
    
      @passphrase = yaml['passphrase']
    
      @public_key_file  = yaml['public_key_file']
      @private_key_file = yaml['private_key_file']
    
      @public_key   = load_key_from_file @public_key_file
      @private_key  = load_key_from_file @private_key_file
    
      keypair = OpenSSL::PKey::RSA.new( @private_key, @passphrase )
    
      key_material.private_key  = keypair
      key_material.public_key   = keypair.public_key
    
      ca.key_material = key_material
    
      unless ca.valid?
        Rails.logger.error "RootCertificate is invalid; errors => #{ca.errors.inspect}"
        raise RootCertificateInvalidException
      end
    
      ca
    end
  
    def load_dn_from_yaml( filename = "#{Rails.root}/config/ca.yml" )
      raise "CA configuration file {filename} does not exist." unless File.exists?( filename )
    
      yaml = YAML::load( File.open(filename) )[ @root_dn ]
    
      dn = CertificateAuthority::DistinguishedName.new
      
      dn.country              = yaml['country']
      dn.state                = yaml['state']
      dn.organization         = yaml['organization']
      dn.organizational_unit  = yaml['organizational_unit']
      dn.locality             = yaml['locality']
      dn
    end
  
    def dn
      @dn ||= load_dn_from_yaml
    end
  
    def load_key_from_file( file )
      File.open( file ).readlines.join("")
    end
  
    def private_key
      @private_key ||= load_key_from_file( @private_key_file )
    end
  
    def client_cert( common_name )
      cert = CertificateAuthority::Certificate.new
    
      cert.subject.common_name          = common_name
      cert.subject.country              = dn.country
      cert.subject.organization         = dn.organization
      cert.subject.organizational_unit  = dn.organizational_unit
      cert.subject.locality             = dn.locality
      cert.parent                       = root
      cert.serial_number.number         = 1 # will serial numbers even be used?      
      
      cert.key_material.generate_key
      cert.sign!
      
      cert
    end
    
  end

  class RootCertificateInvalidException; end
  
end

