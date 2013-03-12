module ConfigurationExtension
  def put(content, path, options={}, &block)
    puttes[path] = {content: content, options: options, block: block}
  end

  def puttes
    @puttes ||= {}
  end
end
