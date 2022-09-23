CREATE TABLE [dbo].[tblDataShareMsgs]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TrailerID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TractorID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RespFormID] [int] NOT NULL,
[SCAC] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LghNbr] [int] NULL,
[MoveNbr] [int] NULL,
[DataSharing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Partner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DTSent] [datetime] NOT NULL,
[DTRcvd] [datetime] NOT NULL,
[RqstSent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DTRqstSent] [datetime] NULL,
[AckSent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DTAckSent] [datetime] NULL,
[Updatedon] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDataShareMsgs] ADD CONSTRAINT [PK_tblDataShareMsgs] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblDataShareMsgs] ON [dbo].[tblDataShareMsgs] ([TrailerID], [SCAC], [RqstSent], [AckSent]) ON [PRIMARY]
GO
