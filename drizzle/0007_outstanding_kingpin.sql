CREATE TABLE `sales_pipeline` (
	`id` int AUTO_INCREMENT NOT NULL,
	`leadId` int NOT NULL,
	`propertyId` int,
	`stage` enum('novo','contato_inicial','qualificado','visita_agendada','visita_realizada','proposta','negociacao','fechado_ganho','fechado_perdido','sem_interesse') NOT NULL DEFAULT 'novo',
	`probability` int DEFAULT 0,
	`estimatedValue` int,
	`enteredAt` timestamp NOT NULL DEFAULT (now()),
	`expectedCloseDate` date,
	`closedAt` timestamp,
	`notes` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `sales_pipeline_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `tasks` (
	`id` int AUTO_INCREMENT NOT NULL,
	`leadId` int NOT NULL,
	`assignedTo` int,
	`title` varchar(255) NOT NULL,
	`description` text,
	`type` enum('ligacao','email','whatsapp','visita','reuniao','proposta','acompanhamento') NOT NULL,
	`priority` enum('baixa','media','alta','urgente') DEFAULT 'media',
	`status` enum('pendente','em_progresso','concluida','cancelada') DEFAULT 'pendente',
	`dueDate` date,
	`completedAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `tasks_id` PRIMARY KEY(`id`)
);
