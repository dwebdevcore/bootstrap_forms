require 'spec_helper'

describe 'BootstrapForms::FormBuilder' do
  context 'given a setup builder' do
    before(:each) do
      @project = Project.new
      @template = ActionView::Base.new
      @template.output_buffer =''
      @builder = BootstrapForms::FormBuilder.new(:item, @project, @template, {}, proc {})
    end

    it_behaves_like 'a bootstrap form'

    context 'with the :namespace option' do
      before(:each) do
        @builder.options[:namespace] = 'foo'
      end

      it 'prefix HTML ids correctly' do
        @builder.text_field('name').should match /<(input) .*id="foo_item_name"/
      end
    end

    context 'with the :index option' do
      before(:each) do
        @builder.options[:index] = 69
      end

      it 'use the correct :index' do
        @builder.text_field('name').should match /<input .*id="item_69_name"/
      end
    end


    context 'with the :namespace and :index options' do
      before(:each) do
        @builder.options[:namespace] = 'foo'
        @builder.options[:index] = 69
      end

      it 'use the correct :index' do
        @builder.text_field('name').should match /<input .*id="foo_item_69_name"/
      end
    end

    context 'without errors' do
      it 'return empty string' do
        @builder.error_messages.should be_empty
      end
    end

    context 'with errors' do
      before(:each) do
        @project.errors.add('name')
        @result = @builder.error_messages
      end

      it 'are wrapped in error div' do
        @result.should match /^<div class="alert alert-block alert-error validation-errors">.*<\/div>$/
      end

      it 'have a list with errors' do
        @result.should match /<ul><li>Name is invalid<\/li><\/ul>/
      end

      it 'have error title' do
        @result.should match /<h4 class="alert-heading">#{I18n.t('bootstrap_forms.errors.header', :model => Project.model_name.human)}<\/h4>/
      end

      it 'have error message on field' do
        @builder.text_field('name').should == "<div class=\"control-group error\"><label class=\"control-label\" for=\"item_name\">Name</label><div class=\"controls\"><input id=\"item_name\" name=\"item[name]\" size=\"30\" type=\"text\" /><span class=\"help-inline\">Name is invalid</span></div></div>"
      end

      it "joins passed error message and validation errors with ', '" do
        @builder.text_field('name', :error => 'This is an error!').should == "<div class=\"control-group error\"><label class=\"control-label\" for=\"item_name\">Name</label><div class=\"controls\"><input id=\"item_name\" name=\"item[name]\" size=\"30\" type=\"text\" /><span class=\"help-inline\">This is an error!, Name is invalid</span></div></div>"
      end
    end

    context 'an attribute with a PresenceValidator' do
      it 'adds the required attribute' do
        @builder.text_field('owner').should match /<input .*required="required"/
      end
    end

    context 'submit' do
      it 'checks persistence of object' do
        @builder.submit.should match('Create Project')
      end
    end

    context 'button' do
      it 'checks persistence of object' do
        @builder.button.should match('Create Project')
      end
    end
  end

  context 'given a setup builder with a symbol' do
    before(:each) do
      @template = ActionView::Base.new
      @template.output_buffer = ''
      @builder = BootstrapForms::FormBuilder.new(:item, nil, @template, {}, proc {})
    end

    it_behaves_like 'a bootstrap form'
  end
end

describe 'BootstrapForms::Helpers::FormTagHelper' do
  describe '#bootstrap_text_field_tag' do
    context 'with no method "validators_on"' do
      before(:each) do
        @non_active_record_object = {:attributes => [:id, :name]}
        @template = ActionView::Base.new
        @template.output_buffer = ""
        @builder = BootstrapForms::FormBuilder.new(:item, @non_active_record_object, @template, {}, proc {})
      end
      it 'returns an empty string with no errors' do
        @template.bootstrap_text_field_tag(@builder.object[:name]).should match /<div class="control-group">.*/
      end
    end
  end
end
