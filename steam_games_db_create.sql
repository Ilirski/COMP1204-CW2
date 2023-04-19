-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-04-19 10:18:49.355

-- tables
-- Table: app
CREATE TABLE app (
    app_id int  NOT NULL,
    app_name varchar(200)  NOT NULL,
    publisher_id int  NOT NULL,
    CONSTRAINT app_pk PRIMARY KEY (app_id)
);

-- Table: app_operating_system
CREATE TABLE app_operating_system (
    app_id int  NOT NULL,
    os_id int  NOT NULL,
    CONSTRAINT app_operating_system_pk PRIMARY KEY (app_id,os_id)
);

-- Table: developer
CREATE TABLE developer (
    developer_id int  NOT NULL,
    developer_name varchar(100)  NOT NULL,
    CONSTRAINT developer_pk PRIMARY KEY (developer_id)
);

-- Table: developer_app
CREATE TABLE developer_app (
    developer_id int  NOT NULL,
    app_id int  NOT NULL,
    CONSTRAINT developer_app_pk PRIMARY KEY (developer_id,app_id)
);

-- Table: log
CREATE TABLE log (
    log_id int  NOT NULL,
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

-- Table: operating_system
CREATE TABLE operating_system (
    os_id int  NOT NULL,
    os_name varchar(20)  NOT NULL,
    CONSTRAINT operating_system_pk PRIMARY KEY (os_id)
);

-- Table: publisher
CREATE TABLE publisher (
    publisher_id int  NOT NULL,
    publisher_name varchar(100)  NOT NULL,
    CONSTRAINT publisher_pk PRIMARY KEY (publisher_id)
);

-- Table: tag
CREATE TABLE tag (
    tag_id int  NOT NULL,
    tag_name varchar(50)  NOT NULL,
    CONSTRAINT tag_pk PRIMARY KEY (tag_id)
);

-- Table: tag_app
CREATE TABLE tag_app (
    tag_id int  NOT NULL,
    app_id int  NOT NULL,
    CONSTRAINT tag_app_pk PRIMARY KEY (tag_id,app_id)
);

-- foreign keys
-- Reference: app_operating_system_app (table: app_operating_system)
ALTER TABLE app_operating_system ADD CONSTRAINT app_operating_system_app FOREIGN KEY app_operating_system_app (app_id)
    REFERENCES app (app_id);

-- Reference: app_operating_system_operating_system (table: app_operating_system)
ALTER TABLE app_operating_system ADD CONSTRAINT app_operating_system_operating_system FOREIGN KEY app_operating_system_operating_system (os_id)
    REFERENCES operating_system (os_id);

-- Reference: app_publisher (table: app)
ALTER TABLE app ADD CONSTRAINT app_publisher FOREIGN KEY app_publisher (publisher_id)
    REFERENCES publisher (publisher_id);

-- Reference: developer_app_app (table: developer_app)
ALTER TABLE developer_app ADD CONSTRAINT developer_app_app FOREIGN KEY developer_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: developer_app_developer (table: developer_app)
ALTER TABLE developer_app ADD CONSTRAINT developer_app_developer FOREIGN KEY developer_app_developer (developer_id)
    REFERENCES developer (developer_id);

-- Reference: log_game (table: log)
ALTER TABLE log ADD CONSTRAINT log_game FOREIGN KEY log_game (app_id)
    REFERENCES app (app_id);

-- Reference: tag_app_app (table: tag_app)
ALTER TABLE tag_app ADD CONSTRAINT tag_app_app FOREIGN KEY tag_app_app (app_id)
    REFERENCES app (app_id);

-- Reference: tag_app_tag (table: tag_app)
ALTER TABLE tag_app ADD CONSTRAINT tag_app_tag FOREIGN KEY tag_app_tag (tag_id)
    REFERENCES tag (tag_id);

-- End of file.

