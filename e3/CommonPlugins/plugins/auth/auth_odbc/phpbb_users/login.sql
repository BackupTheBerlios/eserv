select user_id as id, username as fname, '' as lname, user_email as email 
from phpbb_users where username='{User}' and user_password=MD5('{Pass}') and user_active=1
