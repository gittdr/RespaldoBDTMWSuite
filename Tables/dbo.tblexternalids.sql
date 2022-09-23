CREATE TABLE [dbo].[tblexternalids]
(
[MCommTypeSN] [int] NOT NULL,
[ExternalID] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TmailObjType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMailObjSN] [int] NULL,
[PageNum] [int] NULL,
[CabUnitSN] [int] NOT NULL CONSTRAINT [DF__tblextern__CabUn__1645E101] DEFAULT ((0)),
[MAPIAddressee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [int] NOT NULL CONSTRAINT [DF__tblextern__Insta__1551BCC8] DEFAULT ((1)),
[DateAndTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblexternalids] ADD CONSTRAINT [pk_tblexternalids_04242015] PRIMARY KEY CLUSTERED ([MCommTypeSN], [ExternalID], [CabUnitSN], [InstanceID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ExternalID_index] ON [dbo].[tblexternalids] ([ExternalID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ExternalIDs_DateAndTime] ON [dbo].[tblexternalids] ([MCommTypeSN], [DateAndTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TMailObjSN_index] ON [dbo].[tblexternalids] ([TMailObjSN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblExtIDByTMailObj] ON [dbo].[tblexternalids] ([TmailObjType], [TMailObjSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblexternalids] TO [public]
GO
GRANT INSERT ON  [dbo].[tblexternalids] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblexternalids] TO [public]
GO
GRANT SELECT ON  [dbo].[tblexternalids] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblexternalids] TO [public]
GO
