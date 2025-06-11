-- liquibase formatted sql

-- changeset jaison.chipuka:137548093839839-1
insert into st_user_type (type_name) values ('ADMIN');
insert into st_user_type (type_name) values ('INTERNAL');
insert into st_user_type (type_name) values ('DRIVER');
insert into st_user_type (type_name) values ('CLIENT');