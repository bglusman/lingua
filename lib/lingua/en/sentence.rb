module Lingua
  module EN
    # The class Lingua::EN::Sentence takes English text, and attempts to
    # split it up into sentences, respecting abbreviations.

    module Sentence
      extend self

      Titles   = [ 'jr', 'mr', 'mrs', 'ms', 'dr', 'prof', 'sr', 'sen', 'rep',
        'rev', 'gov', 'atty', 'supt', 'det', 'rev', 'col','gen', 'lt',
        'cmdr', 'adm', 'capt', 'sgt', 'cpl', 'maj' ] unless defined?(Titles)
      Entities = [ 'dept', 'univ', 'uni', 'assn', 'bros', 'inc', 'ltd', 'co',
        'corp', 'plc' ] unless defined?(Entities)
      Months   = [ 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul',
        'aug', 'sep', 'oct', 'nov', 'dec', 'sept' ] unless defined?(Months)
      Days     = [ 'mon', 'tue', 'wed', 'thu',
                   'fri', 'sat', 'sun' ] unless defined?(Days)
      Misc     = [ 'vs', 'etc', 'no', 'esp', 'cf' ] unless defined?(Misc)
      Streets  = [ 'ave', 'bld', 'blvd', 'cl', 'ct',
                   'cres', 'dr', 'rd', 'st' ] unless defined?(Streets)


      # Finds abbreviations, like e.g., i.e., U.S., u.S., U.S.S.R.
      ABBR_DETECT = /(?:\s(?:(?:(?:\w\.){2,}\w?)|(?:\w\.\w)))/ unless defined?(ABBR_DETECT)

      # Finds punctuation that ends paragraphs.
      PUNCTUATION_DETECT = /((?:[\.?!]|[\r\n]+)(?:\"|\'|\)|\]|\})?)(\s+)/ unless defined?(PUNCTUATION_DETECT)

      EOS = "\001" unless defined?(EOS) # temporary end of sentence marker      

      CORRECT_ABBR = /(#{ABBR_DETECT})#{EOS}(\s+[a-z0-9])/

      @abbreviations = Titles + Entities + Months + Days + Streets + Misc


      # Split the passed text into individual sentences, trim these and return
      # as an array. A sentence is marked by one of the punctuation marks ".", "?"
      # or "!" followed by whitespace. Sequences of full stops (such as an
      # ellipsis marker "..." and stops after a known abbreviation are ignored.
      def self.sentences(text)
        # Make sure we work with a duplicate, as we are modifying the
        # text with #gsub!
        text = text.dup

        # Mark end of sentences with EOS marker.
        # We preserve the trailing whitespace ($2) so that we can
        # fix ellipses (...)!
        text.gsub!(PUNCTUATION_DETECT) { $1 << EOS << $2 }

        # Correct ellipsis marks.
        text.gsub!(/(\.\.\.*)#{EOS}/) { $1 }

        # Correct e.g, i.e. marks.
        text.gsub!(CORRECT_ABBR, "\\1\\2")

        # Correct abbreviations
        text.gsub!(abbr_regex) { $1 << '.' }

        # Split on EOS marker, get rid of trailing whitespace.
        # Remove empty sentences.
        text.split(EOS).
          map { |sentence| sentence.strip }.
          delete_if { |sentence| sentence.nil? || sentence.empty? }
      end

      # Adds a list of abbreviations to the list that's used to detect false
      # sentence ends. Return the current list of abbreviations in use.
      def self.abbreviation(*abbreviations)
        @abbreviations << abbreviations
        @abbreviations.uniq!
        @abbreviations
      end

      def abbr_regex
        / (#{@abbreviations.join("|")})\.#{EOS}/i
      end
    end
  end
end
