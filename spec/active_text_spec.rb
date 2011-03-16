require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveText" do
  describe "given properly formatted input" do
    before do
      @text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";

// @name Masthead BG Color
// @kind color
// @description Background color.
$mbc: #555;}
    end

    it "should be able to set variables and return them properly" do
      @atb = ActiveText::Base.new(@text)

      @atb.mbc.name.should == "Masthead BG Color"
      @atb.mbc.kind.should == "color"
      @atb.mbc.description.should == "Background color."
      @atb.mbc.value.should == "#555"

      @atb.mbc2.name.should == "Masthead Background Image"
      @atb.mbc2.kind.should == "file"
      @atb.mbc2.description.should == "Background image."
      @atb.mbc2.value.should == %Q("http://someurl.com/image.jpg")
    end
  end
end
