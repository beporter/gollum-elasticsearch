module Fakes
  class Backend
    def initialize(save: nil, search: nil)
      @save = save
      @search = search
    end

    def save(path, attrs)
      @save
    end

    def search(q)
      @search
    end
  end
end
