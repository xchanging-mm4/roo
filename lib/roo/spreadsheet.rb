# frozen_string_literal: true
require 'uri'

module Roo
  class Spreadsheet
    class << self
      def open(path, options = {})
        path      = path.path if path.respond_to?(:path)
        extension = extension_for(path, options)

        begin
          Roo::CLASS_FOR_EXTENSION.fetch(extension).new(path, options)
        rescue KeyError
          raise ArgumentError,
                "Can't detect the type of #{path} - please use the :extension option to declare its type."
        end
      end

      # rubocop:disable Metrics/MethodLength
      def extension_for(path, options)
        case (extension = options.delete(:extension))
        when ::Symbol
          options[:file_warning] = :ignore
          extension
        when ::String
          options[:file_warning] = :ignore
          extension.tr('.', '').downcase.to_sym
        else
          parsed_path =
            if path =~ /\A#{::URI::DEFAULT_PARSER.make_regexp}\z/
              # path is 7th match
              Regexp.last_match[7]
            else
              path
            end
          ::File.extname(parsed_path).tr('.', '').downcase.to_sym
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
