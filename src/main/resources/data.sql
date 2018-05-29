-- User roles: Admin, Moderator, Normal user etc.
create table if not exists user_roles
(
	id serial not null
		constraint roles_pkey
			primary key,
	name varchar(15)
)
;

-- User status: (un)confirmed, banned etc.
create table if not exists user_states
(
	id smallserial not null
		constraint states_pkey
			primary key,
	name varchar(12)
)
;

-- Здесь хранятся адреса кошельков, и тех на которые надо кидать деньги,
-- и те, на которые происходят вывод средств. Всё это для того, чтобы не дублировать адреса.
create table if not exists wallets
(
	id bigserial not null
		constraint wallets_pkey
			primary key,
	address varchar(100) not null,
	balance numeric(15,10) default 0 not null,
	our boolean default false not null
)
;

-- Files.
create table if not exists storage
(
	id bigserial not null
		constraint storage_pkey
			primary key,
	file_directory varchar(255),
	file_extension varchar(255),
	file_name varchar(255)
)
;

-- Users.
create table if not exists users
(
	id serial not null
		constraint users_pkey
		primary key,
	login varchar(50) not null,
	password varchar(60) not null,
	email varchar(254),
	role_id smallint not null
		constraint users_roles_id_fk
		references user_roles
		on update cascade,
	state smallint not null
		constraint users_states_id_fk
		references user_states
		on update cascade,
	money numeric(15,10) default 0,
	reg_date timestamp not null,
	wallet bigint
		constraint users_wallets_id_fk
		references wallets,
	image_id bigint
		constraint image_storage_id_fk
		references storage,
	state_id integer,
	temp_password varchar(255),
	uuid varchar(255)
		constraint uk_6km2m9i3vjuy36rnvkgj1l61s
		unique
)
;

create table if not exists transaction_states
(
	id smallserial not null
		constraint transaction_states_pkey
		primary key,
	name varchar(15)
)
;

create unique index if not exists transaction_states_id_uindex
	on transaction_states (id)
;


-- История ввода и вывода денег.
create table if not exists transactions
(
	id bigserial not null
		constraint transactions_pkey
			primary key,
	user_id bigint not null
		constraint transactions_users_id_fk
			references users,
	amount numeric(15,10) not null,
	from_wallet bigint not null
		constraint transactions_wallets_id_fk
			references wallets,
	to_wallet bigint not null
		constraint transactions_wallets_id_fk_2
			references wallets,
	date timestamp,
	state smallint
		constraint transactions_transaction_states_id_fk
			references transaction_states
				on update cascade,
	fee numeric(15,10),
	txid varchar(64)
)
;

-- Статус цели: в процессе достижения, достигнута, не достигнута, сохранена в черновиках.
create table if not exists goal_states
(
	id smallserial not null
		constraint goal_states_pkey
			primary key,
	name varchar(15) not null
)
;

-- Goals.
create table if not exists goals
(
	id bigserial not null
		constraint goals_pkey
		primary key,
	user_id bigserial not null
		constraint fkb1mp6ulyqkpcw6bc1a2mr7v1g
		references users
		constraint goals_users_id_fk
		references users,
	name varchar(64) not null,
	description varchar(1500),
	money numeric(15,10),
	state smallint not null
		constraint goals_goal_states_id_fk
		references goal_states
		on update cascade,
	date_end timestamp,
	date_start date,
	price numeric(19,2),
	title varchar(255),
	image bigint
		constraint goals_storage_id_fk
		references storage
)
;

-- Список транзакций с внутренним счётом пользователя. Сюда входят история отпарвки
-- денег на цель, возврат денег после выполнения цели и отправка денег
-- другим пользователям (если будет реализовано).
-- direction = true - деньги получены после выполнения цели
-- direction = false - деньги отправлены на цель
create table if not exists money_history
(
	id bigserial not null
		constraint money_history_pkey
		primary key,
	user_id bigint not null
		constraint money_history_users_id_fk
		references users
		on update cascade,
	goal bigint not null
		constraint money_history_goals_id_fk
		references goals
		on update cascade,
	direction smallint not null,
	amount numeric(15,10) not null,
	date timestamp
)
;

create table if not exists checkpoints
(
	id bigserial not null
		constraint checkpoints_pkey
		primary key,
	amount integer,
	completed integer,
	description varchar(255),
	name varchar(255),
	goal_id bigint
		constraint checkpoint_goal_id_fk
		references goals
)
;

create table if not exists goal_followers
(
	id bigserial not null
		constraint goal_followers_pkey
		primary key
)
;

create table if not exists users_followings
(
	id bigserial not null
		constraint users_followings_pkey
		primary key,
	following_id integer
		constraint follower_id_fk
		references users,
	user_id integer
		constraint user_id_fk
		references users
)
;

create table if not exists persistent_logins (
	username varchar(64) not null,
	series varchar(64) not null,
	token varchar(64) not null,
	last_used timestamp not null,
	PRIMARY KEY (series)
);

INSERT INTO user_roles (id, name)
  SELECT 0, 'Empty'
  WHERE NOT EXISTS (SELECT name FROM user_roles WHERE name = 'Empty');

INSERT INTO user_roles (id, name)
  SELECT 1, 'Admin'
  WHERE NOT EXISTS (SELECT name FROM user_roles WHERE name = 'Admin');

INSERT INTO user_roles (id, name)
  SELECT 2, 'Moderator'
  WHERE NOT EXISTS (SELECT name FROM user_roles WHERE name = 'Moderator');

INSERT INTO user_roles (id, name)
  SELECT 3, 'User'
  WHERE NOT EXISTS (SELECT name FROM user_roles WHERE name = 'User');

INSERT INTO user_states (id, name)
  SELECT 0, 'Active'
  WHERE NOT EXISTS (SELECT name FROM user_states WHERE name = 'Active');

INSERT INTO user_states (id, name)
  SELECT 1, 'Banned'
  WHERE NOT EXISTS (SELECT name FROM user_states WHERE name = 'Banned');

INSERT INTO user_states (id, name)
  SELECT 2, 'Not active'
  WHERE NOT EXISTS (SELECT name FROM user_states WHERE name = 'Not active');

INSERT INTO goal_states (id, name)
  SELECT 0, 'In progress'
  WHERE NOT EXISTS (SELECT name FROM goal_states WHERE name = 'In progress');

INSERT INTO goal_states (id, name)
  SELECT 1, 'Completed'
  WHERE NOT EXISTS (SELECT name FROM goal_states WHERE name = 'Completed');

INSERT INTO goal_states (id, name)
  SELECT 2, 'Failed'
  WHERE NOT EXISTS (SELECT name FROM goal_states WHERE name = 'Failed');

INSERT INTO goal_states (id, name)
  SELECT 3, 'Draft'
  WHERE NOT EXISTS (SELECT name FROM goal_states WHERE name = 'Draft');

INSERT INTO transaction_states (id, name)
  SELECT 0, 'Sent'
  WHERE NOT EXISTS (SELECT name FROM transaction_states WHERE name = 'Sent');

INSERT INTO transaction_states (id, name)
  SELECT 1, 'Received'
  WHERE NOT EXISTS (SELECT name FROM transaction_states WHERE name = 'Sent');

INSERT INTO transaction_states (id, name)
  SELECT 2, 'Send failed'
  WHERE NOT EXISTS (SELECT name FROM transaction_states WHERE name = 'Sent');

INSERT INTO transaction_states (id, name)
  SELECT 3, 'Receive failed'
  WHERE NOT EXISTS (SELECT name FROM transaction_states WHERE name = 'Sent');

-- INSERT INTO public.goal_states (id, name) VALUES (3, 'Draft');
INSERT INTO public.goal_states (id, name) VALUES (1, 'Completed');
INSERT INTO public.goal_states (id, name) VALUES (2, 'Failed');
INSERT INTO public.goal_states (id, name) VALUES (0, 'Test');
--
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (1, '2018-04-20', 'Lorem ipsum', null, 1, 2, 'Test title', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (2, '2018-05-29', 'Lorem ipsum 2', null, 1, 2, 'Lorem ipsum', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (3, '2018-05-29', 'Lorem ipsum 3', null, 1, 2, 'Lorem ipsum', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (4, '2018-05-29', 'Lorem ipsum 4', null, 1, 2, 'Lorem ipsum', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (5, '2018-05-31', 'Lorem ipsum 5', null, 1, 2, 'Lorem ipsum', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (6, '2018-04-12', 'Lorem ipsum 5', null, 1, 2, 'Lorem ipsum 6', '2018-04-04', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (7, '2018-04-12', 'Lorem ipsum 5', null, 1, 2, 'Nibba what', '2018-04-08', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (26, '2018-04-30', 'test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description test Description ', 2.00, 1, 2, 'this is test goal', '2018-04-10', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (27, '2018-04-30', 'выебать роберта', null, 1, 2, 'выебать роберта', '2018-04-22', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (28, '2018-05-29', 'To become master of programming', null, 1, 2, '10000 hours of coding', '2018-04-22', 'test',  null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (42, '2018-05-31', 'And win a grant', 20.00, 0, 2, null, '2018-05-14', 'Pass Academic Session', null);
-- INSERT INTO public.goals (id, date_end, description, price, state, user_id, title, date_start, name,  image) VALUES (59, '2018-06-30', 'test description', 228.00, 0, 2, null, '2018-05-27', 'this is test goal',  null);
--
-- INSERT INTO public.persistent_logins (username, series, token, last_used) VALUES ('qwerty007', '3Ol8Vp08ci+aeh127SQ3Ag==', 'iZa9q6UO/aa0+AaJEioOpA==', '2018-04-21 22:56:28.168000');
-- INSERT INTO public.persistent_logins (username, series, token, last_used) VALUES ('test1', 'FGlJWkhV1+ic5gvjeZBk2A==', 'OtyCkuiZaPZpQrxcn7lvlg==', '2018-04-27 20:10:52.401000');
-- INSERT INTO public.persistent_logins (username, series, token, last_used) VALUES ('jerddys', 'JFGWtQ+YcJAuYI0CzSSxZQ==', 'cOWFmxPPfQYYwMyjd9i95Q==', '2018-05-28 22:50:42.069000');
--
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (8, 'C:/test', 'jpg', '2.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (9, 'C:/test', 'jpg', 'YNFX6b1D1Y.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (10, 'C:/test', 'jpg', '2(1).jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (11, 'C:/test', 'jpg', 'EdSBzV1Gah4.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (12, 'C:/test', 'jpg', 'YNFX6b1D1Y(1).jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (13, 'C:/test', 'jpg', '92f57e0e-aa50-497a-8380-b701e359995e.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (14, 'C:/test', 'txt', '0a78a8f2-c0ae-4ec2-bade-60a5b0c5737a.txt');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (15, 'C:/test', 'jpg', '67d497bb-87be-4319-9bba-7bdafefc6931.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (16, 'C:/test', 'jpg', '0ebd81ae-4116-44b6-952e-2a8411a9415b.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (17, 'C:/test', 'jpg', '4b983743-eb28-4ce4-8a02-60e7f114f8c5.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (18, 'C:/test', 'jpg', '52f785fb-6620-4289-ae0c-2adb05a4c0da.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (19, 'C:/test', 'jpg', '8f87d4a2-2493-4022-968e-83b3d2e7e836.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (20, 'C:/test', 'jpg', '4e3f4e5c-92e5-4509-a104-92b217aba52f.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (21, 'C:/test', 'png', '9746f7cd-72cd-4cfd-8d85-59396bddcc4d.png');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (22, 'C:/test', 'jpg', 'ef7c2f7f-4bd0-47a2-8ad8-ade5c9e1916b.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (23, 'C:/test', 'jpg', 'bb66e24a-f0f3-4cf5-8ed8-cdcf06799603.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (24, 'C:/test', 'jpg', '5e7c2f8e-5416-47d2-bda7-622af3835a70.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (25, 'C:/test', 'jpg', '395c760e-03d8-4fd9-9b7f-d2b514113b0c.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (26, 'C:/test', 'jpg', 'b9199b99-08ef-4cae-815b-c50fd6c24774.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (27, 'C:/test', 'jpg', 'd66f95ef-fa00-483b-b19f-27da8a1c6fab.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (28, 'C:/test', 'jpg', '33ecaa08-61b5-44da-887f-e327555ab369.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (29, 'C:/test', 'jpg', 'f75ace9e-f1f9-428d-a62c-c92b4831fb46.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (30, 'C:/test', 'jpg', 'f881d298-7ac1-4540-9310-cff0c3471123.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (31, 'C:/test', 'jpg', 'db6f2441-4afe-4ca9-9978-c04056be9434.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (32, 'C:/test', 'jpg', '211678da-5d3f-4f1e-b5d7-f068bb46c687.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (33, 'C:/test', 'jpg', '43120c5d-1341-4e1c-8979-9bed050228eb.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (34, 'C:/test', 'jpg', '0bbac5cd-7ea0-4fd3-b55b-b258b7292fe2.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (35, 'C:/test', 'jpg', '540c70e2-3d8e-490f-8481-01d1accfffb0.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (36, 'C:/test', 'jpg', '9d45ef64-db5e-4395-90d4-bdc9c0ee5ffe.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (37, 'C:/test', 'jpg', 'b40e3ee5-f36a-4a12-8baf-43c54a4094ab.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (38, 'C:/test', 'jpg', '71af8b19-d550-4d03-82a0-9780d9d46610.jpg');
-- INSERT INTO public.storage (id, file_directory, file_extension, file_name) VALUES (39, 'C:/test', 'jpg', '9d5c60a0-a1fe-4e73-b8b5-80bd37296f92.jpg');
--
--
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (1, 2.00, '2018-05-14', 29, 30, 1, 123456789.00, 1, 'wertyuiolmgfds', 29, 30, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (31, 0.00, '2018-04-16', 29, 30, 2, 0.00, 0, '6fc01279c6fcc6d34f7d89e73e530ebe9de2cd4b8a53221ec46d4d127b698ed9', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (82, 0.00, '2018-04-16', null, null, 2, 0.00, 0, '6fc01279c6fcc6d34f7d89e73e530ebe9de2cd4b8a53221ec46d4d127b698ed9', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (83, 0.00, '2018-04-17', null, null, 2, 0.00, 0, 'c1f3afbcf851a6d3adc31ddd5eb0d05820634a700ed26fb5997ad1183e90f7ac', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (84, 0.00, '2018-04-17', null, null, 2, 0.00, 0, 'e1418fce1d33513aa2cce3c4c4072cbaaec3104023969020c3492e9b9876a2a0', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (85, 0.00, '2018-04-17', null, null, 2, 0.00, 0, '2fe39f085b7f5d89743f3ed7844d1734fb885e5b956728017f5ea91225e4dbe0', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (86, 0.00, '2018-04-17', null, null, 2, 0.00, 0, '12aab55679301e0616649a75f1d17b68bdb2528cb3b0155a6a574343546bd991', 30, 29, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (87, 0.00, '2018-05-08', null, null, 1, 0.00, 0, '598d3457fe825535174b0602dc56fd4e466259b2798e26ee621b8038e42a5be8', 29, 30, null, null);
-- INSERT INTO public.transactions (id, amount, date, fromwallet_id, towallet_id, user_id, fee, state, txid, from_wallet, to_wallet, from_wallet_id, to_wallet_id) VALUES (88, 0.00, '2018-05-08', null, null, 1, 0.00, 0, 'b1fb205eab147430f7e3e9ae577dfe2cb2dee13c75df712a121901983eef061b', 29, 30, null, null);
--
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (1, 1, 4);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (2, 1, 9);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (18, 2, 8);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (24, 2, 9);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (26, 2, 22);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (27, 2, 1);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (29, 2, 21);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (30, 2, 5);
-- INSERT INTO public.user_relations (id, user_id, following_id) VALUES (31, 28, 2);
--
--
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet,state) VALUES (11, 'test3@test.com', 'test15', 0.00, '123456', null, 3, 1, null, null, 8,  null,1);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (8, 'test1@test.com', 'testuser2', 0.00, '$2a$10$ZXPMO/mt6wp59LvuDDI9/.EZY1wlWtlrUvEbYFC.ZHsjvePZqcB.2', '2018-04-07', 3, 1, null, '4fd09877-06a3-43c9-8619-1342eeedbda6', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (1, 'email1@gmail.com', 'testlogin1', 11.00, '$2a$10$hPEGxdo7wshTU.u8Y/7Ts.jOtZSKE52e03WsCqWRoiTylrXsvOz5O', '2018-04-03', null, null, null, null, 8,  29);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (9, 'eugene@mail.ru', 'eugene', 0.00, '$2a$10$cznLKn1D3.QkR3OG2U5tROE97tp/7U3/TLKx0CriIbs1wKmrRaRe.', '2018-04-08', 3, 3, null, '2794bde9-7058-4e7d-bd24-c61c947595ec', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (14, 'g573138@nwytg.com', 'nigga1', 0.00, '$2a$10$hG3QHLySZDuJkvr.wrqXTOOV3tr3Y9744ntKkjUBiBXp65tB.3p9C', '2018-04-09', 3, 1, null, null, 8, null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (12, 'test123@test.com', 'test16', 0.00, '$2a$10$jPGlklQGOOhkBK4Yz4ytC.dtDWfTEEnTqOekIfjz828ey2gAUVicy', '2018-04-08', 3, 1, null, '8247a946-038f-4e6f-830e-7b8a8c8ba380', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (6, 'g145369@nwytg.com', 'testuser1', 0.00, '$2a$10$cI8M8rju3YzfNALSvM2b3e6JeM7BIT2Jow/ty/ujS5ucKrZ/cmtg2', '2018-04-07', 3, 3, null, '485d2858-908d-44a8-b40e-c86f255ae16d', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (4, 'stacya@gmail.com', 'stacya', 0.00, '$2a$10$GGPL6e.oQLqY41XM0GZ2E.0ei25//ndQKWeW2q1bycNKDQkzthxZm', '2018-04-07', 3, 3, null, '60374a14-6b8d-4eb8-873e-2ee48c3611f8', 8, null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (5, 'kurica_jenshina@mail.ru', 'stacy1', 0.00, '$2a$10$7BDrN4xtJta3VUupg/0KLetVIvGfOt66e6cO51rkZItjW6uf6.Zfe', '2018-04-07', 3, 3, null, 'b383e581-5e31-47b4-9adf-9c03aa379d04', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (26, 'g2545555@nwytg.com', 'jerdys', 0.00, '$2a$10$L.tKat3w6s0nVuwq0eNl9OiTAralLGsN1Klaz3qBSBxmHXwq8kOwe', '2018-04-21', 3, 1, null, 'fcd4c1cd-b6b0-4b24-8df3-f9e4bfcd037d', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (27, 'g2557611@nwytg.com', 'qwerty007', 0.00, '$2a$10$iStUMzoSYE30ry3dxzD68.sKmB8smJDFwA0U3lnMFBRQ7T3098vQy', '2018-04-21', 3, 1, null, null, 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (25, 'g2050119@nwytg.com', 'nashviller', 0.00, '$2a$10$WLcQFGVJWc4gaVpl1pLK6eSN4pp5.7RpFnmqif3M.vxvxLRcyrcPS', '2018-04-18', 3, 1, null, 'c11feb7c-dd15-4f04-b7f0-b5e40e2420b7', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (35, 'i570509@nwytg.com', 'nikita', 0.00, '$2a$10$2cwAbGCUujv5nLsA0kKXV.u50CkVxzePL552pMTWldZhDN.Jygxu6', '2018-05-27', 3, 1, null, 'd9b3959f-878a-4d8f-800a-a41335da56a8', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (13, 'jerddys.b@gmail.com', 'jerdddys', 0.00, '$2a$10$izdKb7SW5IfYpIdXNfKCU.ZQgBmWmw/6WByCSsasW9suXLCECl2wa', '2018-04-08', 3, 1, null, 'b1ad57db-09cf-478e-a72e-e8fc91f8ff32', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (28, 'g3443396@nwytg.com', 'test1', 0.00, '$2a$10$F/mlDfFAj7DPuFEDGZXB9uYwb1ZKYcC4Z.XKf5pmhGVjiu237H0nK', '2018-04-27', 3, 3, null, '9a4ba7b3-db89-4e7d-a91e-6df886fd2669', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (17, 'g575805@nwytg.com', 'nigga2', 0.00, '$2a$10$IztxQtJ5FWLaUNbz44biJuj11pd2CUbLqK.PTVJ25OOUfFHqCq4ue', '2018-04-09', 2, 2, null, 'c890c52a-dc31-4ef1-90ef-787d4d897425', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (22, 'g716317@nwytg.com', 'klimov', 0.00, '$2a$10$BofDBLGIitFpI5tvIAWJG.o0VIfk5wOkUqYFekEbKeaOJnHc6kHzy', '2018-04-10', 3, 3, null, 'b987349a-8d7c-4409-a371-d76010ca6af4', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (21, 'g576890@nwytg.com', 'nigga3', 0.00, '$2a$10$ogkiHDh3O9mZF52vZy37WONXjHVCqxF284SBWIbOqoalXQUiC6Hou', '2018-04-09', 3, 3, null, '7380161b-5a2a-4bc0-8a24-3b212c10054d', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (10, 'e5601310@nwytg.com', 'eugene1', 0.00, '$2a$10$TpINimQ9c2xbj5zqLmolk.7j.rWjBXBzStMEJUKaGj9egn/8Gwfke', '2018-04-08', 3, 3, null, 'f912d28b-a581-4c24-9892-872956d7c941', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (3, 'test@test.com', 'testuser', 0.00, '$2a$10$op0j8tjGyU01nvFAvyx3ue0WJHMyB8kK6wJpVLzIiKdQorHb1KlgC', '2018-04-07', 3, 1, null, 'c86704ed-53ac-41bf-b204-e1c2f051f771', 8,  null);
-- INSERT INTO public.users (id, email, login, money, password, reg_date, role_id, state_id, temp_password, uuid, image_id,  wallet) VALUES (2, 'jerdys.b@gmail.com', 'jerddys', 500.00, '$2a$10$diqHT.bnK91nsfoWJv1v9.CXzS8TbiQTd/9HI1H7LjKMmtBFczyWa', '2018-04-03', 3, 1, null, '542c305c-daa3-445c-8855-6b2501d3b8ea', 39,  30);
