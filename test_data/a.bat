set TOP_DIR=C:\Users\ykomi\cur\ruby\ykutils
set TD_DIR=%TOP_DIR%\test_data
set V103_DIR=%TD_DIR%\v103-3-189-127
set A_DIR=%V103_dir%\a.northern-cross.net
bundle exec ruby %TOP_DIR%\bin\erubix  %V103_DIR%\template_ssl.erb %A_DIR%\value_host.yml %V103_DIR%\value_ssl.yml
