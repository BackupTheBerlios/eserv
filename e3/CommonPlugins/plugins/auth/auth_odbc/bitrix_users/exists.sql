select id, name as fname, last_name as lname, email
from b_user where login='{User}' and active='Y'
