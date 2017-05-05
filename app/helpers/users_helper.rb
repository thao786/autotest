module UsersHelper
  def own? (object)
    if object
      case object.class.name
        when 'Step'
          current_user == object.test.suite.user
        when 'Test'
          current_user == object.suite.user
        when 'Suite'
          current_user == object.user
        else
          false
      end
    else
      true
    end
  end
end
