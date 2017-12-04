# frozen_string_literal: true

if defined?(ChefSpec)
  ChefSpec.define_matcher :dropwizard_pleaserun

  define_method 'create_dropwizard_pleaserun' do |resource_name|
    ChefSpec::Matchers::ResourceMatcher.new(:dropwizard_pleaserun, :create, resource_name)
  end

  define_method 'remove_dropwizard_pleaserun' do |resource_name|
    ChefSpec::Matchers::ResourceMatcher.new(:dropwizard_pleaserun, :create, resource_name)
  end
end
