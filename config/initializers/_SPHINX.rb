if defined? ThinkingSphinx
  # Version >5
  class ThinkingSphinx::Settings
    private

    def file
      @file ||= Pathname.new(framework.root).join 'config', "_THINKING_SPHINX.yml"
    end
  end
end
