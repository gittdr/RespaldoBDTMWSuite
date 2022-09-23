CREATE TABLE [dbo].[directroutehdr]
(
[drh_id] [int] NOT NULL,
[drh_status] [int] NOT NULL,
[drh_userID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drh_dcID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drh_algorithm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drh_loadtype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drh_dispatchdate] [datetime] NULL,
[drh_arriveatdc] [datetime] NULL,
[drh_distancelaststoptodc] [decimal] (9, 1) NULL,
[drh_insertdate] [datetime] NULL CONSTRAINT [DF_directroutehdr_drh_insertdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[directroutehdr] ADD CONSTRAINT [PK__directroutehdr__148A83B8] PRIMARY KEY CLUSTERED ([drh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[directroutehdr] TO [public]
GO
GRANT INSERT ON  [dbo].[directroutehdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[directroutehdr] TO [public]
GO
GRANT SELECT ON  [dbo].[directroutehdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[directroutehdr] TO [public]
GO
