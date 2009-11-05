$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'activesupport'
require 'activeresource'

# The official ruby library for interacting with the RESTful API of mite,
# a sleek time tracking webapp.

module Mite
  
  class << self
    attr_accessor :email, :password, :host_format, :domain_format, :protocol, :port
    attr_reader :account, :key

    # Sets the account name, and updates all resources with the new domain.
    def account=(name)
      resources.each do |klass|
        klass.site = klass.site_format % (host_format % [protocol, domain_format % name, ":#{port}"])
      end
      @account = name
    end

    # Sets up basic authentication credentials for all resources.
    def authenticate(user, password)
      resources.each do |klass|
        klass.user = user
        klass.password = password
      end
      @user     = user
      @password = password
      true
    end

    # Sets the mite.api key for all resources.
    def key=(value)
      resources.each do |klass|
        klass.headers['X-MiteApiKey'] = value
      end
      @key = value
    end

    def resources
      @resources ||= []
    end
  end
  
  self.host_format   = '%s://%s%s'
  self.domain_format = '%s.mite.yo.lk'
  self.protocol      = 'http'
  self.port          = ''
  
  class MethodNotAvaible < StandardError; end
  
  module NoWriteAccess
    def save
      raise MethodNotAvaible, "Cannot save #{self.class.name} over mite.api"
    end

    def create
      raise MethodNotAvaible, "Cannot save #{self.class.name} over mite.api"
    end

    def destroy
      raise MethodNotAvaible, "Cannot save #{self.class.name} over mite.api"
    end
  end
  
  class Base < ActiveResource::Base
    class << self
      
      def inherited(base)
        unless base == Mite::SingletonBase
          Mite.resources << base
          class << base
            attr_accessor :site_format
          end
          base.site_format = '%s'
          base.timeout = 20
        end
        super
      end
      
      # Common shortcuts known from ActiveRecord
      def all(options={})
        find_every(options)
      end

      def first(options={})
        find_every(options).first
      end

      def last(options={})
        find_every(options).last
      end
      
      # Undo destroy action on the resource with the ID in the +id+ parameter.
      def undo_destroy(id)
        returning(self.new(:id => id)) { |res| res.undo_destroy }
      end
    end
    
    # Undo destroy action.
    def undo_destroy
      path = element_path(prefix_options).sub(/\.([\w]+)/, '/undo_delete.\1')
      
      returning connection.post(path, "", self.class.headers) do |response|
        load_attributes_from_response(response)
      end
    end
  
  end
  
  class SingletonBase < Base
    include NoWriteAccess
    
    class << self
      def collection_name
        element_name
      end

      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
      end

      def collection_path(prefix_options = {}, query_options = nil) 
        prefix_options, query_options = split_options(prefix_options) if query_options.nil? 
        "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}" 
      end
    end
    
    def find
      super(1)
    end

    def first
      find
    end

    # Prevent collection methods

    def all
      raise MethodNotAvaible, "Method not supported on #{self.class.name}"
    end
  end
  
end



require 'mite/customer'
require 'mite/project'
require 'mite/service'
require 'mite/time_entry'
require 'mite/time_entry_group'
require 'mite/tracker'
require 'mite/user'
require 'mite/myself'
require 'mite/account'