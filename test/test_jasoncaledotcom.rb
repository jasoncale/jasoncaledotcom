require 'test_helper'

class JasoncaledotcomTest < Test::Unit::TestCase

  context "Jasoncaledotcom" do
    
    context "get /" do
      setup do
        get '/'
      end
      
      should "respond" do
        assert body
      end
    end
    

    context "get /:id" do
      setup do
        get '/:id'
      end
      
      should "respond" do
        assert body
      end
    end
    
  end

end