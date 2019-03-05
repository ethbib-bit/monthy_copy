# Monthly Copy

Application that makes a tar backup file of previous month Rosetta storage and moves it to LTS.

## Application use

* Use start_monthly.sh to start program
* Configuration is done in config/monthly_copy.ini


## Current Version: 2.2


### History

### 2.20 (2019-05-29)

* add checker if to be tarred folders actually exist
* add info message to recipients
* implement cron and documenation

### 2.10 (2019-03-11)

* Replaced line break items in Helper class
* added complete Config::Simple library in case it is not installed on server

### 2.00 (2019-03-06)

* complete refactoring _done_
* implement copy logic _done_
* implement compress logic _done_
* implement cleanup _done_
* setup of Perl skeleton _done_
* check if all involved storage exists _done_
* flexible config file _done_
* use history _done_
* use last_run _done_

### 1.00

* Initial old shell version
* requires start at 1st of month
* copies from NAS to HSM to LTS
