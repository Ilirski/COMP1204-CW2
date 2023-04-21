-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-04-21 10:16:21.565

-- tables
-- Table: app
CREATE TABLE app (
    app_id int  NOT NULL,
    app_name varchar(200)  NOT NULL,
    app_type varchar(20)  NOT NULL,
    app_store_name varchar(50)  NULL,
    app_change_number char(8)  NOT NULL,
    app_last_change_date timestamp  NOT NULL,
    app_release_date timestamp  NULL,
    CONSTRAINT app_pk PRIMARY KEY (app_id)
);

-- Table: app_developer
CREATE TABLE app_developer (
    app_id int  NOT NULL,
    developer_id int  NOT NULL,
    CONSTRAINT developer_app_pk PRIMARY KEY (developer_id,app_id)
);

-- Table: app_franchise
CREATE TABLE app_franchise (
    app_id int  NOT NULL,
    franchise_id int  NOT NULL,
    CONSTRAINT developer_app_pk PRIMARY KEY (franchise_id,app_id)
);

-- Table: app_os
CREATE TABLE app_os (
    app_id int  NOT NULL,
    os_id int  NOT NULL,
    CONSTRAINT app_operating_system_pk PRIMARY KEY (os_id,app_id)
);

-- Table: app_publisher
CREATE TABLE app_publisher (
    app_id int  NOT NULL,
    publisher_id int  NOT NULL,
    CONSTRAINT developer_app_pk PRIMARY KEY (publisher_id,app_id)
);

-- Table: app_tag
CREATE TABLE app_tag (
    app_id int  NOT NULL,
    tag_id int  NOT NULL,
    CONSTRAINT tag_app_pk PRIMARY KEY (tag_id,app_id)
);

-- Table: developer
CREATE TABLE developer (
    developer_id int  NOT NULL AUTO_INCREMENT,
    developer_name varchar(100)  NOT NULL,
    CONSTRAINT developer_pk PRIMARY KEY (developer_id)
);

-- Table: franchise
CREATE TABLE franchise (
    franchise_id int  NOT NULL AUTO_INCREMENT,
    franchise_name varchar(100)  NOT NULL,
    CONSTRAINT developer_pk PRIMARY KEY (franchise_id)
);

-- Table: log
CREATE TABLE log (
    log_id int  NOT NULL AUTO_INCREMENT,
    logged_at timestamp  NOT NULL,
    players_live int  NOT NULL,
    players_24h_peak int  NOT NULL,
    players_all_time_peak int  NOT NULL,
    twitch_viewers int  NOT NULL,
    twitch_viewers_24h_peak int  NOT NULL,
    twitch_viewers_all_time_peak int  NOT NULL,
    store_followers int  NOT NULL,
    store_top_seller_pos int  NOT NULL,
    store_pos_reviews int  NOT NULL,
    store_nev_reviews int  NOT NULL,
    owner_review_low int  NOT NULL,
    owner_review_high int  NOT NULL,
    owner_playtracker int  NOT NULL,
    owner_vg_insights int  NOT NULL,
    owner_steamspy int  NOT NULL,
    app_id int  NOT NULL,
    CONSTRAINT log_pk PRIMARY KEY (log_id)
);

-- Table: os
CREATE TABLE os (
    os_id int  NOT NULL AUTO_INCREMENT,
    os_name varchar(20)  NOT NULL,
    UNIQUE INDEX os_ak_1 (os_name),
    CONSTRAINT operating_system_pk PRIMARY KEY (os_id)
);

-- Table: publisher
CREATE TABLE publisher (
    publisher_id int  NOT NULL AUTO_INCREMENT,
    publisher_name varchar(100)  NOT NULL,
    CONSTRAINT publisher_pk PRIMARY KEY (publisher_id)
);

-- Table: tag
CREATE TABLE tag (
    tag_id int  NOT NULL AUTO_INCREMENT,
    tag_name varchar(50)  NOT NULL AUTO_INCREMENT,
    UNIQUE INDEX tag_ak_1 (tag_name),
    CONSTRAINT tag_pk PRIMARY KEY (tag_id)
);

-- foreign keys
-- Reference: app_operating_system_app (table: app_os)
ALTER TABLE app_os ADD CONSTRAINT app_operating_system_app FOREIGN KEY app_operating_system_app (app_id)
    REFERENCES app (app_id);

-- Reference: app_operating_system_operating_system (table: app_os)
ALTER TABLE app_os ADD CONSTRAINT app_operating_system_operating_system FOREIGN KEY app_operating_system_operating_system (os_id)
    REFERENCES os (os_id);

-- Reference: developer_app_app (table: app_developer)
ALTER TABLE app_developer ADD CONSTRAINT developer_app_app FOREIGN KEY developer_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: developer_app_developer (table: app_developer)
ALTER TABLE app_developer ADD CONSTRAINT developer_app_developer FOREIGN KEY developer_app_developer (developer_id)
    REFERENCES developer (developer_id);

-- Reference: franchise_app_app (table: app_franchise)
ALTER TABLE app_franchise ADD CONSTRAINT franchise_app_app FOREIGN KEY franchise_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: franchise_app_franchise (table: app_franchise)
ALTER TABLE app_franchise ADD CONSTRAINT franchise_app_franchise FOREIGN KEY franchise_app_franchise (franchise_id)
    REFERENCES franchise (franchise_id);

-- Reference: log_game (table: log)
ALTER TABLE log ADD CONSTRAINT log_game FOREIGN KEY log_game (app_id)
    REFERENCES app (app_id);

-- Reference: publisher_app_app (table: app_publisher)
ALTER TABLE app_publisher ADD CONSTRAINT publisher_app_app FOREIGN KEY publisher_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: publisher_app_publisher (table: app_publisher)
ALTER TABLE app_publisher ADD CONSTRAINT publisher_app_publisher FOREIGN KEY publisher_app_publisher (publisher_id)
    REFERENCES publisher (publisher_id);

-- Reference: tag_app_app (table: app_tag)
ALTER TABLE app_tag ADD CONSTRAINT tag_app_app FOREIGN KEY tag_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: tag_app_tag (table: app_tag)
ALTER TABLE app_tag ADD CONSTRAINT tag_app_tag FOREIGN KEY tag_app_tag (tag_id)
    REFERENCES tag (tag_id);

-- End of file.

