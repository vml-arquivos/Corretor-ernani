CREATE TABLE `interestRates` (
	`id` int AUTO_INCREMENT NOT NULL,
	`bankName` varchar(100) NOT NULL,
	`rateType` enum('sac','price') NOT NULL,
	`annualRate` decimal(5,3) NOT NULL,
	`startDate` date NOT NULL,
	`endDate` date,
	`source` varchar(255),
	`lastUpdated` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `interestRates_id` PRIMARY KEY(`id`)
);
