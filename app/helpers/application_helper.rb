module ApplicationHelper
  include TimeTools

  def bytes_to_bp(sz)
    # return a file size in binary prefix notation, SI units
    bprefix = Array.new

    bprefix[0] = "KiBi"
    bprefix[1] = "MiBi"
    bprefix[2] = "GiBi"
    bprefix[3] = "TiBi"
    bprefix[4] = "PiBi"
    bprefix[5] = "EiBi"
    bprefix[6] = "ZiBi"
    bprefix[7] = "YiBi"

    i = 1
    bprefix.each{ |k|
      v = 1024 ** i
      if sz < 1024 ** (i+1)
        return sprintf("%.03f %s", sz.to_f / v.to_f, k)
      end
      i = i + 1
    }
  end

end
