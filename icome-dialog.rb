# coding: utf-8
module Dialog
  include_package 'java.awt'
  include_package 'javax.swing'

  def dialog(s)
    JOptionPane.showMessageDialog(nil, "<html>#{s}</html>", "icome",
                                  JOptionPane::INFORMATION_MESSAGE)
  end

  def query?(s)
    ans = JOptionPane.showConfirmDialog(nil, "<html>#{s}</html>", "icome",
                                        JOptionPane::YES_NO_OPTION)
    ans == JOptionPane::YES_OPTION
  end

  def option_dialog(ss, query)
    ans = JOptionPane.showOptionDialog(nil,"<html>#{query}</html>", "icome",
                                       JOptionPane::YES_NO_OPTION,
                                       JOptionPane::QUESTION_MESSAGE,
                                       nil, ss, ss[0])
  end

end

