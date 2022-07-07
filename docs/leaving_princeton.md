# Leaving Princeton

When an admin assistant leaves their position, follow these steps:

1. Remove them from `config/departments.yml`
1. When your change has been merged, deploy to prod
1. On a production server:
```
cd /opt/approvals/current
bundle exec rake approvals:remove_admin_assistant[netid]
```