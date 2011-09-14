require 'spec_helper'
require 'shoulda-matchers'

describe ProjectPrivilege do

  it { should belong_to( :role    ) }
  it { should belong_to( :project ) }
  it { should belong_to( :user    ) }

  it { should validate_presence_of( :role_id    ) }
  it { should validate_presence_of( :project_id ) }
  it { should validate_presence_of( :user_id    ) }

end
