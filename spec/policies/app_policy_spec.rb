require 'spec_helper'

RSpec::Matchers.define :permit do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end

describe AppPolicy do
  subject { AppPolicy.new(user, app) }

  let(:team_one) { FactoryGirl.create(:team) }
  let(:team_two) { FactoryGirl.create(:team) }

  let(:app) { FactoryGirl.create(:app, team: team_one) }

  context "normal user in team one" do
    let(:user) { FactoryGirl.create(:admin, team: team_one)}
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:edit)    }
    it { is_expected.to permit(:destroy) }
  end

  context "normal user in team two" do
    let(:user) { FactoryGirl.create(:admin, team: team_two)}
    it { is_expected.not_to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end

  context "super admin in team two" do
    let(:user) { FactoryGirl.create(:admin, team: team_two, super_admin: true)}
    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:new) }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:edit)    }
    it { is_expected.not_to permit(:destroy) }
  end
end