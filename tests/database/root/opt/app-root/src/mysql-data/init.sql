CREATE TABLE `visitors` (
    `id` enum('1') NOT NULL,
    `number` int(6) DEFAULT '0',
    PRIMARY KEY (`id`)
) COMMENT='The ENUM(''1'') construct as primary key is used to prevent that more than one row can be entered to the table';

INSERT INTO `visitors` (`number`) VALUES('0');
