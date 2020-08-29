class Class

  def types_of(sym, &block)
    #save old method first
    old_method = "__#{sym.to_s}__".to_sym
    alias_method old_method, sym

    parameters = self.get_parameters_from_method sym
    #create a type checker and overwrite the original method with the new one
    type_checker = TypeChecker.new parameters, &block
    self.send :define_method, sym.to_sym do |*params|
      new_params = self.class.implicitly_transform *params
      type_checker.validate_types(*new_params, sym.to_sym)
      self.send old_method.to_sym, *new_params
    end
  end

  def get_parameters_from_method(sym)
    unbound_method = self.instance_method(sym.to_sym)
    unbound_method.parameters.map { |p| p[1] }
  end

  def implicitly_transform(*params)
    implicits = Implicits.get_implicits_by self
    implicits.each do |implicit|
      params = implicit.check_implicit *params
    end
    params
  end

end

class TypeChecker

  attr_accessor :parameters, :validators

  def initialize(parameters, &block)
    self.parameters = parameters
    self.validators = []
    self.instance_eval &block
  end

  def param(param_sym, type)
    self.validators.push(TypeCheckerValidator.new(param_sym, type))
  end

  def validate_types(*params, method_sym)
    raise "Invalid number of parameters for method #{method_sym}" unless self.parameters.length == params.length

    zipped_params = self.parameters.zip(params)
    zipped_params.each do |param_name, param_value|
      validator=self.validators.select { |validator| validator.param == param_name }[0]
      validator.validate_value_type(param_value)
    end
  end

end

class TypeCheckerValidator

  attr_accessor :param, :type

  def initialize(param, type)
    self.param = param
    self.type = type
  end

  def validate_value_type(value)
    raise "TypeError: #{value} is not type of #{self.type}" unless value.class == self.type
  end

end


#Implicit feature
class Implicit
  attr_accessor :for_klass, :conversion, :condition

  def for_class(klass)
    self.for_klass=klass
  end

  def check_implicit(*params)
    condition = self.condition.call *params
    if condition
      return self.convert_params(*params)
    end
    params
  end

  def convert_params(*params)
    self.conversion.call *params
  end

end

#This class is used for keeping a collection of implicits
class Implicits
  @@implicits = []

  def self.add(implicit)
    @@implicits.push(implicit)
  end

  def self.implicits
    @@implicits || []
  end

  def self.get_implicits_by(klass)
    self.implicits.select { |implicit| implicit.for_klass == klass }
  end

  def self.clean_implicits
    @@implicits= []
  end

end

