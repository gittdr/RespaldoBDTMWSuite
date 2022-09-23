CREATE TABLE [dbo].[BillToStopHierarchy]
(
[BillTo] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pickup_sequence] [int] NULL,
[drop_sequence] [int] NULL,
[stopType_sequence] [int] NULL,
[stopType_abbr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updated_by] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BillToStopHierarchy] ADD CONSTRAINT [PK__BillToStopHierar__70099701] PRIMARY KEY CLUSTERED ([BillTo]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BillToStopHierarchy] TO [public]
GO
GRANT INSERT ON  [dbo].[BillToStopHierarchy] TO [public]
GO
GRANT REFERENCES ON  [dbo].[BillToStopHierarchy] TO [public]
GO
GRANT SELECT ON  [dbo].[BillToStopHierarchy] TO [public]
GO
GRANT UPDATE ON  [dbo].[BillToStopHierarchy] TO [public]
GO
