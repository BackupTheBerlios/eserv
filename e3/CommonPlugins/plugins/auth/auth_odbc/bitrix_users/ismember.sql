select b_group.name from b_user, b_user_group, b_group where b_user.login='{User}' and b_user_group.user_id=b_user.id and b_user_group.group_id=b_group.id and b_group.name='{s}'
