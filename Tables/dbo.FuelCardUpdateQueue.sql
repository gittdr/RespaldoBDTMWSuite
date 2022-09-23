CREATE TABLE [dbo].[FuelCardUpdateQueue]
(
[fcuq_id] [int] NOT NULL IDENTITY(1, 1),
[fcuq_update_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fcuq_asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fcuq_asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[fcuq_updatedon] [datetime] NOT NULL,
[fcuq_retry_count] [int] NULL CONSTRAINT [DF__FuelCardU__fcuq___6F7EE960] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[dt_FuelCardUpdateQueue] on [dbo].[FuelCardUpdateQueue] for  delete as
SET NOCOUNT ON 

insert into FuelCardUpdateQueueAudit
	(
	fcuq_id,
	fcuq_update_type,
	fcuq_asgn_type,
	fcuq_asgn_id,
	lgh_number,
	fcuq_updatedon,
	fcuqa_processedon) 
	(select
	fcuq_id,
	fcuq_update_type,
	fcuq_asgn_type,
	fcuq_asgn_id,
	lgh_number,
	fcuq_updatedon,
	getdate()
	from deleted
	)


GO
GRANT DELETE ON  [dbo].[FuelCardUpdateQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelCardUpdateQueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelCardUpdateQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelCardUpdateQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelCardUpdateQueue] TO [public]
GO
