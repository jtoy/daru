# :nocov:
def jruby?
  RUBY_ENGINE == 'jruby'
end
# :nocov:

module Daru
  DAYS_OF_WEEK = {
    'SUN' => 0,
    'MON' => 1,
    'TUE' => 2,
    'WED' => 3,
    'THU' => 4,
    'FRI' => 5,
    'SAT' => 6
  }.freeze

  MONTH_DAYS = {
    1 => 31,
    2 => 28,
    3 => 31,
    4 => 30,
    5 => 31,
    6 => 30,
    7 => 31,
    8 => 31,
    9 => 30,
    10 => 31,
    11 => 30,
    12 => 31
  }.freeze

  @lazy_update = false

  SPLIT_TOKEN = ','.freeze

  @plotting_library = :nyaplot

  class << self
    # A variable which will set whether Vector metadata is updated immediately or lazily.
    # Call the #update method every time a values are set or removed in order to update
    # metadata like positions of missing values.
    attr_accessor :lazy_update
    attr_reader :plotting_library

    def create_has_library(library)
      lib_underscore = library.to_s.tr('-', '_')
      define_singleton_method("has_#{lib_underscore}?") do
        cv = "@@#{lib_underscore}"
        unless class_variable_defined? cv
          begin
            library = 'nmatrix/nmatrix' if library == :nmatrix
            require library.to_s
            class_variable_set(cv, true)
          rescue LoadError
            # :nocov:
            class_variable_set(cv, false)
            # :nocov:
          end
        end
        class_variable_get(cv)
      end
    end

    def plotting_library= lib
      case lib
      when :gruff, :nyaplot
        @plotting_library = lib
      else
        raise ArgumentError, "Unsupported library #{lib}"
      end
    end
  end

  create_has_library :gsl
  create_has_library :nmatrix
  create_has_library :nyaplot
  create_has_library :gruff
end

[['reportbuilder', '~>1.4'], ['spreadsheet', '~>1.1.1']].each do |lib|
  begin
    gem lib[0], lib[1]
    require lib[0]
  rescue LoadError
    STDERR.puts "\nInstall the #{lib[0]} gem version #{lib[1]} for using"\
    " #{lib[0]} functions."
  end
end

autoload :CSV, 'csv'
require 'matrix'

require 'daru/version.rb'

require 'daru/helpers/array.rb'
require 'daru/index.rb'
require 'daru/vector.rb'
require 'daru/dataframe.rb'
require 'daru/monkeys.rb'
require 'daru/formatters/table'
require 'daru/iruby/helpers'
require 'daru/exceptions.rb'

require 'daru/core/group_by.rb'
require 'daru/core/query.rb'
require 'daru/core/merge.rb'

require 'daru/date_time/offsets.rb'
require 'daru/date_time/index.rb'

require 'backports'
