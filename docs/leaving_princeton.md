# Leaving Princeton

When an admin assistant leaves PUL, follow these steps:

1. Remove them from `config/departments.yml`
1. On a production server:
```
cd /opt/approvals/current
bundle exec rake approvals:stop_being_a_delegate\[netid\]
```