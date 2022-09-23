CREATE TABLE [dbo].[carrier411_batch_update_status]
(
[cab_batch_number] [int] NOT NULL,
[cbu_update_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cbu_batch_date] [datetime] NULL,
[cbu_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cbu_batchcount] [int] NULL,
[cbu_batch_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411_batch_update_status] ADD CONSTRAINT [PK__carrier411_batch__1B544F7C] PRIMARY KEY CLUSTERED ([cab_batch_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411_batch_update_status] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411_batch_update_status] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411_batch_update_status] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411_batch_update_status] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411_batch_update_status] TO [public]
GO
