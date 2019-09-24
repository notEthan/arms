# third party coders. we put them here so that the external libraries do not have to have ARMS as a dependency.

ARMS.register_coder_shortcut(:jsi) { |s| JSI::JSICoder.new(*s.args) }
