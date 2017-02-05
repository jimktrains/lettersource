module LettersHelper
  class HTMLConverterWithoutLinks < Kramdown::Converter::Html 
    def convert_a(el, indent)
      inner(el, indent)
    end
  end
end
