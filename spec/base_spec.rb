require 'spec_helper'

describe ActivePresenter::Base do
  context "when SignupPresenter is set as new" do
    let(:presenter) { SignupPresenter.new }

    it "returns no ID" do
      expect(presenter.id).to be nil
    end

    it "is a new record" do
      expect(presenter.new_record?).to be true
    end

    it "is not be valid" do
      expect(presenter).not_to be_valid
      expect(SignupPresenter.new(user: User.new(hash_for_user))).to be_valid
    end

    it { expect(presenter.respond_to?(:user_login)).to be }
    it { expect(presenter.respond_to?(:user_password_confirmation)).to be }
    it { expect(presenter.respond_to?(:valid?)).to be } # just making sure i didn't break everything :)
    it { expect(presenter.respond_to?(:nil?, false)).to be } # making sure it's possible to pass 2 arguments

    it { expect(presenter.attributes = nil).to eq nil }

    it { expect(SignupPresenter.human_attribute_name(:user_login)).to eq('Login') }

    it { expect { SignupPresenter.new({:i_dont_exist=>"blah"}) }.to raise_error(NoMethodError) }

    it { expect(presenter.changed?).to be_falsy }
    it {
      p = SignupPresenter.new(:user => User.new(hash_for_user))
      p.save
      p.user_login = 'something_else'
      expect(p.changed?).to be
    }

    it "returns an ActiveRecord::RecordInvalid" do
      expect { presenter.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "was raising with nil" do
      expect(SignupPresenter.new(nil).class).to eq SignupPresenter
    end

    context "when it try to set with an unexisting params" do
      it "raise a NoMethodError" do
        expect{ SignupPresenter.new({:i_dont_exist=>"blah"}) }.to raise_error(NoMethodError)
      end
    end

    context "on validation" do
      before do
        presenter.valid?
      end

      it "returns an ActiveModel::Errors" do
        expect(presenter.errors.class).to be ActiveModel::Errors
        expect(presenter.user_errors.class).to be ActiveModel::Errors
        expect(presenter.account_errors.class).to be ActiveModel::Errors
      end

      it "returns a error message" do
        expect(presenter.errors[:user_login]).to eq(["can't be blank"])
      end

      it "returns full messages" do
        expect(presenter.errors.full_messages).to eq(["User login can't be blank", "User Password can't be blank"])
      end

      context "when user password is set" do
        let(:presenter) { SignupPresenter.new(user_password: 'foo', user_password_confirmation: 'foo') }

        it "returns full messages" do
          expect(presenter.errors.full_messages).to eq(["User login can't be blank"])
        end
      end

      context "when locale change" do
        it "returns localize error message" do
          message = when_locale_changed do
            s = SignupPresenter.new(user_login: nil)
            s.valid?
            s.errors[:user_login]
          end

          expect(message).to eq(['c4N n07 83 8L4nK'])
        end

        it "returns localize full error messages" do
          message = when_locale_changed do
            s = SignupPresenter.new(user_login: 'login')
            s.valid?
            s.errors.full_messages
          end

          expect(message).to eq(['U53R pa22w0rD c4N n07 83 8L4nK'])
        end
      end
    end

    context "User login" do
      it "sets login User" do
        expect_any_instance_of(User).to receive(:login=).with('james')
        SignupPresenter.new(user_login: 'james')
      end

      it "returns the user_login value" do
        expect_any_instance_of(User).to receive(:login).and_return('mymockvalue')
        SignupPresenter.new.user_login
      end

      it "use `user_login` to set login's User" do
        expect_any_instance_of(User).to receive(:login=).with('mymockvalue')
        SignupPresenter.new.user_login = 'mymockvalue'
      end
    end

    context "when it try to saved the presenter" do
      it { expect(presenter.save).not_to be }

      it "uses a transaction" do
        expect(ActiveRecord::Base).to receive(:transaction)
        presenter.save
      end

      it "returns error message" do
        presenter.save
        expect(presenter.errors[:user_login]).to eq(["can't be blank"])
      end

      context "when the user is set" do
        let(:presenter) { SignupPresenter.new(user: User.new(hash_for_user)) }

        it "try to save the user" do
          expect_any_instance_of(User).to receive(:save)
          presenter.save
        end

        it "try to save the account" do
          expect_any_instance_of(Account).to receive(:save)
          presenter.save
        end
        #it "rollbacks" do
          #allow(ActiveRecord::Base).to receive(:transaction).and_yield
          #expect_any_instance_of(User).to receive(:save).and_return(false)
          #expect_any_instance_of(Account).to receive(:save).and_return(false)

          #expect(presenter.save).to be ActiveRecord::Rollback
        #end
      end
    end

    context "when it try to saved! the presenter" do
      it "returns error message" do
        presenter.save! rescue
        expect(presenter.errors[:user_login]).to eq(["can't be blank"])
      end

      context "when user_login and user_password is set" do
        let(:presenter) { SignupPresenter.new(user_login: "da", user_password: "seekrit") }

        it "uses a transaction" do
          expect(ActiveRecord::Base).to receive(:transaction)
          presenter.save!
        end

        it "try to save the user" do
          expect_any_instance_of(User).to receive(:save)
          presenter.save
        end

        it "try to save the account" do
          expect_any_instance_of(Account).to receive(:save)
          presenter.save
        end
      end

      context "the user is valid" do
        let(:presenter) { SignupPresenter.new(user: User.new(hash_for_user)) }

        it "saves the user" do
          expect(presenter.save!).to be
        end
      end
    end

    context "when update_attributes" do
      it "set all attributes" do
        presenter.update_attributes(user_login: 'Something Different')
        expect(presenter.user_login).to eq('Something Different')
      end

      it "can use multiparameter assignment" do
        presenter.update_attributes({
          :"user_birthday(1i)" => '1980',
          :"user_birthday(2i)" => '3',
          :"user_birthday(3i)" => '27',
          :"user_birthday(4i)" => '9',
          :"user_birthday(5i)" => '30',
          :"user_birthday(6i)" => '59'
        })
        expect(presenter.user_birthday).to eq(Time.parse('March 27 1980 9:30:59 am UTC'))
      end

      context "when user exist" do
        let(:user) { User.create!(hash_for_user) }
        let(:presenter) { SignupPresenter.new(user: user) }

        it "does not changed login" do
          presenter.update_attributes(user_login: 'Something Totally Different')
          expect(user).not_to be_login_changed
        end

        it "try to save the presenter" do
          expect(presenter).to receive(:save)
          presenter.update_attributes user_login: 'Something'
        end
      end
    end
  end

  context "when presenter have after some callbacks" do
    it "calls it" do
      %w(save save!).each do |save_method|
        presenter = AfterSavePresenter.new
        presenter.send(save_method)
        expect(presenter.address.street).to eq('Some Street')
      end
    end

    it { expect { CallbackCantSavePresenter.new.save! }.to raise_error(ActiveRecord::RecordNotSaved) }

    context "when presenter cant validate the presenter" do
      let(:cant_save_presenter) { CallbackCantValidatePresenter.new }

      it { expect { cant_save_presenter.save! }.to raise_error(ActiveRecord::RecordInvalid) }

      it "returns ordering callback list for save method" do
        expect([:before_validation]).to eq(
          returning(cant_save_presenter) do |presenter|
            begin
              presenter.save
            rescue ActiveRecord::RecordInvalid
              # NOP
            end
          end.steps
        )
      end

      it "returns ordering callback list for save! method" do
        expect([:before_validation]).to eq(
          returning(cant_save_presenter) do |presenter|
            begin
              presenter.save!
            rescue ActiveRecord::RecordInvalid
              # NOP
            end
          end.steps
        )
      end

      it "clear Errors before validation" do
        expect_any_instance_of(ActiveModel::Errors).to receive(:clear).at_least(:once)
        cant_save_presenter.valid?
      end
    end

    context "ordering callbacks" do
      let(:presenter) { CallbackOrderingPresenter.new }

      it "calls callbacks" do
        expect([:before_validation, :before_save, :after_save]).to eq(
          returning(presenter) do |pres|
            pres.save!
          end.steps
        )

        expect([:before_validation, :before_save, :after_save, :before_validation, :before_save, :after_save]).to eq(
          returning(presenter) do |pres|
            pres.save
          end.steps
        )

        expect([:before_validation, :before_save, :after_save, :before_validation, :before_save, :after_save, :before_validation, :before_save, :after_save]).to eq(
          returning(presenter) do |pres|
            begin
              pres.save!
            rescue ActiveRecord::RecordNotSaved
              # NOP
            end
          end.steps
        )
      end
    end
  end

  context "When is not set" do
    it { expect(SignupNoAccountPresenter.new.save).not_to be }
    it { expect(SignupNoAccountPresenter.new(:user => User.new(hash_for_user), :account => nil).save).to be }
    it { expect(SignupNoAccountPresenter.new(:user => User.new(hash_for_user), :account => nil).save!).to be }
  end

  context "when presenter have 2 addresses" do
    it "returns secondary address" do
      expect(PresenterWithTwoAddresses.new.secondary_address.class).to eq(Address)
    end

    it "return secondary address street value" do
      p = PresenterWithTwoAddresses.new(:secondary_address_street => "123 awesome st")
      p.save
      expect(p.secondary_address_street).to eq("123 awesome st")
    end
  end

  context "when use Presenter as Decorator" do
    it { expect(DecoratedUser.new).not_to be_valid }

    it "Effectively removes type prefixes on attributes" do
      expect(DecoratedUser.new.user.class).to eq(User)
    end

    it "return attribute value" do
      expect_any_instance_of(User).to receive(:login).and_return('mymockvalue')
      expect(DecoratedUser.new.login).to eq('mymockvalue')
    end

    it "sets attribute value" do
      expect_any_instance_of(User).to receive(:login=).with('mymockvalue')
      DecoratedUser.new.login = 'mymockvalue'
    end

    it "returns error message" do
      u = DecoratedUser.new
      u.valid?
      expect(u.errors[:login]).to eq(["can't be blank"])
    end

    it "returns full error message" do
      u = DecoratedUser.new(:password => 'foo', :password_confirmation => 'foo')
      u.valid?
      expect(u.errors.full_messages).to eq(["Login can't be blank"])
    end

    context "when it try to save" do
      it { expect{ DecoratedUser.new.save! }.to raise_error(ActiveRecord::RecordInvalid) }

      it { expect(DecoratedUser.new.save).not_to be }

      it "uses a transaction" do
        expect(ActiveRecord::Base).to receive(:transaction)
        DecoratedUser.new.save
      end

      it "forward save to User" do
        expect_any_instance_of(User).to receive(:save)
        DecoratedUser.new :user => User.new(hash_for_user).save
      end

      context "when login and password are set" do
        let(:decorated_user) { DecoratedUser.new(:login => "da", :password => "seekrit") }

        it { expect(DecoratedUser.new(:user => User.new(hash_for_user)).save!).to be }

        it "uses a transaction" do
          expect(ActiveRecord::Base).to receive(:transaction)
          decorated_user.save
        end

        it "forward save! to User" do
          expect_any_instance_of(User).to receive(:save!)
          decorated_user.save!
        end
      end
    end
  end

  context "when DecoratedUserWithTags" do
    let(:decorator) { DecoratedUserWithTags.new :user => User.new(hash_for_user) }

    context "without tags" do
      it "does not be valid" do
        expect(decorator.valid?).to be_falsy
      end

      it "returns error message" do
        decorator.valid?
        expect(decorator.errors[:tags]).to eq(["can't be blank"])
      end
    end

    context "with tags" do
      context "when user is new User" do
        it "valids" do
          decorator_with_tags = DecoratedUserWithTags.new :user => User.new(hash_for_user)
          decorator.tags = "Tall, Mammal"

          expect(decorator_with_tags).to be_truthy
        end
      end

      context "when set with hash params" do
        it "valids" do
          decorator_with_tags = DecoratedUserWithTags.new hash_for_user
          decorator.tags = "Tall, Mammal"

          expect(decorator_with_tags).to be_truthy
        end
      end

      context "when set with hash params with tags key" do
        it "valids" do
          decorator_with_tags = DecoratedUserWithTags.new hash_for_user.merge({tags: "Tall, Mammal"})

          expect(decorator_with_tags).to be_truthy
        end
      end
    end
  end

  it { expect(EndingWithSPresenter.new.address).not_to be_nil }

  it { expect(CantSavePresenter.new.save).not_to be } # it won't save because the filter chain will abort
  it { expect{ CantSavePresenter.new.save! }.to raise_error(ActiveRecord::RecordNotSaved) }

  it { expect(SamePrefixPresenter.new.respond_to?(:account_title)).to be }
  it { expect(SamePrefixPresenter.new.respond_to?(:account_info_info) ).to be }

  it {
    p = HistoricalPresenter.new(:history_comment => 'comment', :user => User.new(hash_for_user))
    p.save

    expect(p.history_comment).to eq("comment")
  }
end

def when_locale_changed
  old_locale = I18n.locale
  I18n.locale = '1337'
  value = yield
  I18n.locale = old_locale
  value
end
