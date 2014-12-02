module Matchers
  extend ::RSpec::Matchers::DSL
  include Capistrano::Spec::Helpers

  define :callback do |task_name|
    match do |configuration|
      @task = configuration.find_task(task_name)
      callbacks = find_callback(configuration, @on, @task)

      if callbacks
        callbacks.any? do |callback|
          if callback && @trigger_task_name
            @trigger_task = configuration.find_task(@trigger_task_name)
            @trigger_task && callback.applies_to?(@trigger_task)
          else
            callback
          end
        end
      else
        false
      end
    end

    def on(on)
      @on = on
      self
    end

    def before(before_task_name)
      @on = :before
      @trigger_task_name = before_task_name
      self
    end

    def after(after_task_name)
      @on = :after
      @trigger_task_name = after_task_name
      self
    end

    failure_message_for_should do |actual|
      if @trigger_task_name
        "expected configuration to callback #{task_name.inspect} #{@on} #{@trigger_task_name.inspect}, but did not"
      else
        "expected configuration to callback #{task_name.inspect} on #{@on}, but did not"
      end
    end

  end

  define :have_putted do |path|
    match do |configuration|
      upload = configuration.puttes[path]
      if @content
        upload && upload[:content] == @content
      else
        upload
      end
    end

    def with(content)
      @content = content
      self
    end

    failure_message_for_should do |actual|
      if @content
        "expected configuration to put #{path} with content '#{@content}', but did not"
      else
        "expected configuration to put #{path}, but did not"
      end
    end
  end
end
