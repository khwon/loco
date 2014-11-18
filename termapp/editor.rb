module TermApp
  class Editor
    def initialize(term)
      @term = term
    end

    def method_missing(meth, *args)
      @term.send(meth, *args)
    end
  end
end
