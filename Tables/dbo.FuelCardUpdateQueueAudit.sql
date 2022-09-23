CREATE TABLE [dbo].[FuelCardUpdateQueueAudit]
(
[fcuq_id] [int] NOT NULL,
[fcuq_update_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fcuq_asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fcuq_asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[fcuq_updatedon] [datetime] NOT NULL,
[fcuqa_processedon] [datetime] NOT NULL,
[fcuq_retry_count] [int] NULL CONSTRAINT [DF__FuelCardU__fcuq___70730D99] DEFAULT ((0))
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelCardUpdateQueueAudit] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelCardUpdateQueueAudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelCardUpdateQueueAudit] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelCardUpdateQueueAudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelCardUpdateQueueAudit] TO [public]
GO
