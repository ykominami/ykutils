@echo off
set TOP_DIR=C:\Users\ykomi\cur\ruby\ykutils
set TD_DIR=%TOP_DIR%\test_data
set V103_DIR=%TD_DIR%\v103-3-189-127
set A_DIR=%V103_dir%\a.northern-cross.net
REM bundle exec ruby %TOP_DIR%\bin\erubix  %V103_DIR%\template_ssl.erb %A_DIR%\value_host.yml %V103_DIR%\value_ssl.yml

REM bundle exec ruby %TOP_DIR%\bin\erubix  %V103_DIR%\template_ssl_www.erb %A_DIR%\value_host.yml %V103_DIR%\value_ssl.yml
REM bundle exec ruby %TOP_DIR%\bin\erubix  %V103_DIR%\template.erb %A_DIR%\value_host.yml %V103_DIR%\value.yml
REM bundle exec ruby %TOP_DIR%\bin\erubix  %V103_DIR%\template_www.erb %A_DIR%\value_host.yml %V103_DIR%\value.yml
bundle exec ruby %TOP_DIR%\bin\erubix2  %A_DIR%\base.yml
