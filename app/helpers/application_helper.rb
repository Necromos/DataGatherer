module ApplicationHelper
  def sigma_host
    request.host == 'sigma.ug.edu.pl' ? request.host+'/~pkrolik/datagatherer' : request.host
  end
end
