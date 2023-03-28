class ErrorSerializer
  def self.no_matches_found(error)
    {
      "data": {
				"errors": error
			}
    }
  end

  def self.invalid_parameters(error) 
    {
      "data": {
				"errors": error
			}
    }
  end

  def self.bad_request(error)
    {
      "errors": error
    }
  end
end