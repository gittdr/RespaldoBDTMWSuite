CREATE TABLE [dbo].[recruitqualifications]
(
[rcq_id] [int] NOT NULL IDENTITY(1, 1),
[rec_id] [int] NOT NULL,
[rcq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rcq_expiredate] [datetime] NULL,
[rcq_expireflag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[recruitqualifications] ADD CONSTRAINT [PK_recruitdetail] PRIMARY KEY CLUSTERED ([rcq_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recruitqualifications] TO [public]
GO
GRANT INSERT ON  [dbo].[recruitqualifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recruitqualifications] TO [public]
GO
GRANT SELECT ON  [dbo].[recruitqualifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[recruitqualifications] TO [public]
GO
