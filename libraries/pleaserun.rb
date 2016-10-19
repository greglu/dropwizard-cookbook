if defined?(ChefSpec)
  ChefSpec.define_matcher :pleaserun

  define_method "create_pleaserun" do |resource_name|
    ChefSpec::Matchers::ResourceMatcher.new(:pleaserun, :create, resource_name)
  end
end
