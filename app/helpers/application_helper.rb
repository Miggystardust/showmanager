module ApplicationHelper

  def sec_to_time(n)
    if n == nil
      return -1
    end

    sprintf "%02d:%02d", (n/60),(n - 60*(n/60))
  end

end
