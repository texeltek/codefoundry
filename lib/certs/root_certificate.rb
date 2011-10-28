require 'certificate_authority'

class RootCertificate
  
  attr_accessor :root_ca
  attr_accessor :config
  
  attr_accessor :public_key
  attr_accessor :private_key
  
  attr_accessor :public_key_file
  attr_accessor :private_key_file
  
  attr_accessor :passphrase
  
  def initialize( file )
    load_from_yaml( file )
  end
  
  def certificate
    @root_ca ||= load_from_yaml
  end
  
  def load_from_yaml( filename="#{Rails.root}/config/ca.yml" )
    raise "ca.yml does not exist; did you copy it from ca.sample.yml?" unless File.exists?( "#{Rails.root}/config/ca.yml" )
    
    yaml = YAML::load( File.open("#{Rails.root}/config/ca.yml") )
    
    root_ca = CertificateAuthority::Certificate.new
    
    # set the root CA's subject information
    root_ca.subject.common_name = yaml['common_name']
    root_ca.subject.locality = yaml['locality']
    root_ca.subject.state = yaml['state']
    root_ca.subject.country = yaml['country']
    root_ca.subject.organization = yaml['organization']
    root_ca.subject.organizational_unit = yaml['organizational_unit']
    
    # this CA will sign other certs, so set to true
    root_ca.signing_entity = yaml['signing_entity'] || true
    
    # get the passphrase from the yaml
    # TODO: FIXME
    # TODO: Find a much more secure way of doing this
    root_ca.passphrase = yaml['passphrase']
    
    # locations of the private
    root_ca.public_key_file = yaml['public_key_file']
    root_ca.private_key_file = yaml['private_key_file']
  
    key_material = CertificateAuthority::MemoryKeyMaterial.new
    
    
    
    key_material.keypair = OpenSSL::PKey::RSA.new( @private_key, @passphrase )
    
    #root.key_material.private_key
  end
  
  
  def load_key_from_file( file )
    File.open( file ).readlines.join("")
  end
  
  def private_key
    @private_key ||= load_key_from_file( @private_key_file )
  end
  
  def public_cert
    @public_cert ||= load_key_from_file( @public_key_file )
  end
  
  def private_key_file
    @private_key_file ||= 
  end
  
  def public_cert_file
    @public_key_file ||= 
  end
end