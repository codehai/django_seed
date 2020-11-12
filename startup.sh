/usr/local/bin/python /app/manage.py migrate
echo yes | /usr/local/bin/python /app/manage.py collectstatic
supervisord -n
