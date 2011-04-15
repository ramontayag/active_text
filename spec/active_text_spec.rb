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

      @atb[:mbc][:name].should == "Masthead BG Color"
      @atb[:mbc][:kind].should == "color"
      @atb[:mbc][:description].should == "Background color."
      @atb[:mbc][:value].should == "#555"

      @atb[:mbc2][:name].should == "Masthead Background Image"
      @atb[:mbc2][:kind].should == "file"
      @atb[:mbc2][:description].should == "Background image."
      @atb[:mbc2][:value].should == %Q("http://someurl.com/image.jpg")
    end
  end

  describe "when assigning values" do
    it "should update its values" do
      text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";}
      @s = ActiveText::Base.new(text)
      @s.mbc2 = %Q("Another URL")
      @s.mbc2.should == %Q("Another URL")

      rendered_text = @s.render
      rendered_text.should_not match(/http:\/\/someurl\.com\/image\.jpg/)
      rendered_text.should match(/\$mbc2: "Another URL";/)

      @s.mbc2 = %Q("Some third URL")
      @s.mbc2.should == %Q("Some third URL")
      rendered_text = @s.render
      rendered_text.should_not match(/\$mbc2: "Another URL";/)
      rendered_text.should match(/\$mbc2: "Some third URL";/)
    end

    it "should render the correct values" do
      text_old = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";}
      text_new = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "Another URL";}
      @s = ActiveText::Base.new(text_old)
      @s.mbc2 = %Q("Another URL")
      @s.render.should == text_new
    end
  end

  describe "when there's no metadata" do
    before do
      @text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";
$mbc: #555;}
      @s = ActiveText::Base.new(@text)
    end

    it "should not allow reading of data" do
      lambda {@s.mbc}.should raise_error(NoMethodError)
    end
  end

  describe ".attributes" do
    it ".attributes should return an empty hash when there are no valid variables" do
      @text = %{
$mbc2: "http://someurl.com/image.jpg";
$mbc: #555;}
      @s = ActiveText::Base.new(@text)
      @s.attributes.should == {}
    end

    it "should only return the valid variables" do
      @text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";
$mbc: #555;}
      @s = ActiveText::Base.new(@text)
      @s.attributes.should == {:mbc2 => %Q("http://someurl.com/image.jpg")}
    end
  end

  it "should allow mass assignment" do
    text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";

// @name Masthead BG Color
// @kind color
// @description Background color.
$mbc: #555;}
    @s = ActiveText::Base.new(text)
    @s.update_attributes(:mbc2 => %Q("Another URL"), :mbc => nil)
    @s.mbc2.should == %Q("Another URL")
    @s.mbc.should == "#555"
  end

  it "should have setter method for variables" do
    text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";
}
    @s = ActiveText::Base.new(text)
    @s.mbc2 = "44"
    @s.mbc2.should == "44"
  end

  it "should not allow to set to nil" do
    text = %{// @name Masthead Background Image
// @kind file
// @description Background image.
$mbc2: "http://someurl.com/image.jpg";
}
    @s = ActiveText::Base.new(text)
    @s.mbc2 = nil
    @s.mbc2.should == %Q("http://someurl.com/image.jpg")
  end
end
