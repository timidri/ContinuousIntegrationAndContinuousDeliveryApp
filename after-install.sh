#!/bin/bash -ex
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable helloworldjavaapp.service
/usr/bin/systemctl start helloworldjavaapp
