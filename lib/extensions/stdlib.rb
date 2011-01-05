class String
  #
  # Converts a lower case and underscored string to UpperCamelCase.
  #
  # Examples:
  #   "build_path".camelcase   # => "BuildPath"
  #
  def camelcase
    self.gsub(/(?:\A|_)(.)/) { $1.upcase }
  end
end
