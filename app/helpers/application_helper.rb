module ApplicationHelper

  def sec_to_time(n)
    if n == nil
      return -1
    end

    sprintf "%02d:%02d", (n/60),(n - 60*(n/60))
  end

  def bytes_to_bp(sz)
    # return a file size in binary prefix notation, SI units
    bprefix = Array.new
    
    bprefix[1] = "KiBi"
    bprefix[2] = "MiBi"
    bprefix[3] = "GiBi"
    bprefix[4] = "TiBi"
    bprefix[5] = "PiBi"
    bprefix[6] = "EiBi"
    bprefix[7] = "ZiBi"
    bprefix[8] = "YiBi"
    
    i = 0
    bprefix.each{ |k|
      v = 1024 ** i
      i = i + 1
      if sz < v
        return sprintf("%.02f %s", sz.to_f / v.to_f, k)
      end
    }
  end

end
