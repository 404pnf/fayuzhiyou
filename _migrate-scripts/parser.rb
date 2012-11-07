# -*- coding: utf-8 -*-
require 'yaml'

# usage: script.rb inputrss outputfolder

f = ARGV[0]
out = File.expand_path ARGV[1]

#p f
#p out


def sanitize(title)
  # tr! 返回 nil 如果没有任何修改，因此也不要使用
  title = title.tr(' `~!@#$%^&*()_+=\|][{}"\';:/?.>,<', '_')
  title = title.tr('－·～！@#￥%……&*（）——+、|】』【『‘“”；：/？。》，《', '_')
  title = title.gsub(/_+/, '_').gsub(/^_/, '').gsub(/_$/, '') # 对开头，结尾和多个 _ 做处理
  # 谨慎使用gsbu!
  # !!!!! gsub!的返回值是修改了的str或者nil，如果
  #没有做任何修改的话就是nil
  # 因此最后需要再直接调一下title让本函数最后的输
  #出是title本身的值 
  # 这个bug困惑了好久好久啊！！
  # gsub!(pattern) → an_enumerator
  # Performs the substitutions of String#gsub in place, 
  # returning str, or nil if no substitutions were performed. 
end

# separate string by date entry like '2012-10-02'
# and keep the date entry
arr = (File.read f).split(/([0-9]{4}-[0-9]{2}-[0-9]{2})/) 
#p arr
arr.shift # 第一个元素是空的 ''
# 现在数组是每两个元素表示一篇文章
['2012-10-02', '题目，分类正文等等', '2012-10-02', '题目分类正文等等']

size = arr.size
if size % 2 == 1
  p "数组数目不对呀，怎么是奇数啊？"
else
  p "数组有 #{size} 个元素，也就是是说有#{size/2}篇文章 "
end

# 每次处理2个数组元素
# 每篇文章正文的格式如下
# 第一行是 题目
# 第二行是 分类，可有多个，分类，应该收集为数组
# 第三行开始是正文
arr.each_slice(2) do |article|
  date = article[0]
  # 将content变为数组，之前的每行是一个元素，多余的\n在split后会变为''
  # 删除这些 '' 元素
  content = article[1]
    .split(/\n/)
    .reject{|i| i == ''}
    .map{|i| i.gsub(/\s+/, ' ')}
    .map{|i| i.gsub(/^\s/, '')}  
  title = content.shift # content 第一行是title

  tags_to_keep = %w( 专家文库  写作指导  双语阅读  法语世界  热门词汇  翻译赏析 语法讲解)
  
  tags = content
    .shift
    .gsub(/,/, ' ')
    .gsub(/  +/, ' ')
    .split
    .select{|tag| tags_to_keep.include? tag }
    .uniq
    .join(',')
  content = content
    .map {|s| s.strip}
    .map {|s| s.gsub(/\s\s+/, ' ')}
    .map {|s| s.gsub(/^\s+/, '')}
    .join("\n\n")
  #  p date
  #  p title
  #  p tags.join(',')
  #  p tags
  #  p content
  safe_title = sanitize(title)
  pretty_title = safe_title.gsub(/_/, ' ')
  yaml_front = <<eof
---
layout: post
title: #{pretty_title}
date: #{date}
categories: [#{tags}]  
---

eof

  #p safe_title
  Dir.mkdir out unless File.exist? out # return true if out is a directory 

  File.open("#{out}/#{date}-#{safe_title}.md", 'w') do |file|
    file.puts yaml_front
    file.puts content
  end

  
end


