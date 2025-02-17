# encoding: utf-8
require 'guard'
require 'guard/guard'

module Guard
  class Annotate < Guard

    autoload :Notifier, 'guard/annotate/notifier'

    def initialize( watchers=[], options={} )
      super

      options[:notify] = true if options[:notify].nil?
      options[:position] = 'before' if options[:position].nil?
      options[:tests] = false if options[:tests].nil?
      options[:routes] = false if options[:routes].nil?
      options[:run_at_start] = true if options[:run_at_start].nil?
    end

    def start
      run_annotate if options[:run_at_start]
    end

    def stop
      true
    end

    def reload
      true
    end

    def run_all
      true
    end

    def run_on_change( paths=[] )
      run_annotate(paths)
    end

    private

    def notify?
      !!options[:notify]
    end

    def annotation_position
      options[:position]
    end

    def annotate_routes?
      options[:routes]
    end

    def annotate_tests_flags
      options[:tests] ? "" : "--exclude tests,fixtures"
    end
    
    def run_annotate(paths)
      annotate_models if paths.any? { |p| p =~ /schema|models/ }
      annotate_routes if paths.any? { |p| p =~ /routes/ } && annotate_routes?
      @result
    end
    
    def annotate_models
      UI.info 'Running annotate models', :reset => true
      started_at = Time.now
      @result = system("bundle exec annotate #{annotate_tests_flags} -p #{annotation_position}")
      Notifier::notify( @result, Time.now - started_at ) if notify?
    end
    
    def annotate_routes
      ::Guard.pause
      
      started_at = Time.now
      UI.info 'Running annotate routes', :reset => true
      @result = system("bundle exec annotate -r")
      Notifier::notify( @result, Time.now - started_at ) if notify?
      
      ::Guard.pause
    end
  end
end
