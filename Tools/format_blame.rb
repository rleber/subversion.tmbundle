# just a small to-html formater for what svn blame gives you.
# made to be compatible with the ruby version included
# in 10.3.7 (1.6.8) but runs also with 1.8
# 
# copyright 2005 torsten becker <torsten.becker@gmail.com>
# no warranty, that it doesn't crash your system.
# you are of course free to modify this.


# fetch some tm things..
$full_file  = ENV['TM_FILEPATH']
$current    = ENV['TM_LINE_NUMBER'].to_i
$tab_size   = ENV['TM_TAB_SIZE'].to_i
$bundle     = ENV['TM_BUNDLE_PATH']


# require the helper, it does some formating, etc:
require $bundle+'/Tools/svn_helper.rb'
include SVNHelper


# to show line numbers in output:
linecount = 1


begin
   make_head( "Subversion blame for '"+$full_file.sub( /^.*\//, '')+"'",
              [ $bundle+"/Stylesheets/svn_style.css",
                $bundle+"/Stylesheets/svn_blame_style.css"] )
   
   puts '<table class="blame"> <tr>' +
            '<th>line</th>' +
            '<th class="revhead">rev</th>' +
            '<th>name</th>' +
            '<th class="codehead">code</th></tr>'
   
   
   $stdin.each_line do |line|
      raise SVNErrorException, line  if line =~ /^svn:/
      
      if line =~ /\s*(\d+)\s*(\w+) (.*)/
         curr_add = ($current == linecount) ? ' current_line' : ''
         
         puts '<tr><td class="linecol">'+ linecount.to_s + "</td>\n" +
                  '<td class="revcol'+curr_add+'">' + $1 + "</td>\n" +
                  '<td class="namecol'+curr_add+'">' + $2 + "</td>\n" +
                  '<td class="codecol'+curr_add+'"><a href="' +
                     make_tm_link( $full_file, linecount) +'">'+ htmlize( $3 ) +
                  "</a></td></tr>\n\n"
         
         linecount += 1
         
      else
         raise NoMatchException, line
      end
      
   end #each_line
   
rescue NoMatchException
   puts '<div class="generic_error"><h2>NoMatchException</h2>'
   puts 'mhh, something with with the regex or svn must be wrong.  this should never happen.<br />'
   puts 'last line: <em>'+htmlize( $! )+'</em><br />please bug-report.</div>'
   
rescue SVNErrorException
   puts '<div class="generic_error"><h2>SVNError</h2>'+ htmlize( $! )+'<br />'
   $stdin.each_line { |line| puts htmlize( line )+'<br />' }
   puts '</div>'
   
# catch unknown exceptions..
rescue => e
   puts '<div class="generic_error"><h2>'+e.class.to_s+'</h2>'
   puts 'reason: <em>'+htmlize( $! )+'</em><br />'
   
   trace = ''; $@.each { |e| trace+=htmlize('  '+e)+'<br />' }
   puts 'trace: <br />'+trace+'</div>'
   
ensure
   make_foot( '</table>' )
end
