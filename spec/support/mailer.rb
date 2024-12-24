# frozen_string_literal: true

def html_email_heading
  "<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    " \
    "<style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    "
end

def html_email_footer
  "\n  </body>\n</html>\n"
end
