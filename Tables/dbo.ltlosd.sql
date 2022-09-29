CREATE TABLE [dbo].[ltlosd]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number] [int] NULL,
[evt_number] [int] NULL,
[osd_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reported_on] [datetime] NULL,
[reported_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_on] [datetime] NULL,
[created_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__ltlosd__INS_TIME__5C225FBD] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltlosd] ADD CONSTRAINT [PK__ltlosd__3213E83F89AFC576] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ltlosd_INS_TIMESTAMP] ON [dbo].[ltlosd] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ltlosd_ordhdr] ON [dbo].[ltlosd] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltlosd] TO [public]
GO
GRANT INSERT ON  [dbo].[ltlosd] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltlosd] TO [public]
GO
GRANT SELECT ON  [dbo].[ltlosd] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltlosd] TO [public]
GO
