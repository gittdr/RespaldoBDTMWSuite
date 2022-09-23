CREATE TABLE [dbo].[directroutetruck]
(
[drt_id] [int] NOT NULL IDENTITY(1, 1),
[drh_id] [int] NULL,
[trc_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[capacity] [decimal] (9, 1) NULL,
[countcapacity] [decimal] (9, 1) NULL,
[volumecapacity] [decimal] (9, 1) NULL,
[drt_oneway] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[directroutetruck] ADD CONSTRAINT [PK__directroutetruck__1A435D0E] PRIMARY KEY CLUSTERED ([drt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[directroutetruck] TO [public]
GO
GRANT INSERT ON  [dbo].[directroutetruck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[directroutetruck] TO [public]
GO
GRANT SELECT ON  [dbo].[directroutetruck] TO [public]
GO
GRANT UPDATE ON  [dbo].[directroutetruck] TO [public]
GO
