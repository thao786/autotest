module Util
  def makeNameId (title)
    title.gsub(/\s/, '_').gsub(/\W/, '')
  end
end