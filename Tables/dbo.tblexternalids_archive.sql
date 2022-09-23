CREATE TABLE [dbo].[tblexternalids_archive]
(
[MCommTypeSN] [int] NOT NULL,
[ExternalID] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TmailObjType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMailObjSN] [int] NULL,
[PageNum] [int] NULL,
[CabUnitSN] [int] NULL,
[MAPIAddressee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [int] NULL,
[DateAndTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblexternalids_archive] ADD CONSTRAINT [PK_tblexternalids_archive] PRIMARY KEY CLUSTERED ([MCommTypeSN], [ExternalID]) ON [PRIMARY]
GO
