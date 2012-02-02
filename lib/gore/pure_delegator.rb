class Gore::PureDelegator < BasicObject
  def initialize(target)
    @target = target
  end

  def call(selector, *args, &block)
    method_missing(selector, *args, &block)
  end

  def method_missing(selector, *args, &block)
    @target.send(selector, *args, &block)
  end
end
  