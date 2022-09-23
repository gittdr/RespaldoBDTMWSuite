CREATE TABLE [dbo].[tblMobileCommType]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MobileCommType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSMobileCommName] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumCols] [smallint] NULL,
[NumRows] [smallint] NULL,
[DefaultDisplayRows] [smallint] NULL,
[CostPerChar] [real] NULL,
[CostPerPage] [real] NULL,
[EnabledUntil] [datetime] NULL,
[ts] [timestamp] NULL,
[XfcID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowIDShare] [int] NULL,
[AllowBlankVersion] [int] NULL,
[IsIDAlpha] [int] NULL,
[IsVersionAlpha] [int] NULL,
[DisplayInMultiMode] [int] NULL,
[NOPending] [int] NULL,
[AllowPasswordConfig] [int] NULL,
[CanLink] [int] NULL,
[CanKeyBlock] [int] NULL,
[PasswordConfigPrompt] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMobileCommType] ADD CONSTRAINT [PK_MobileCommType] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_MCT_DIMM] ON [dbo].[tblMobileCommType] ([DisplayInMultiMode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMobileCommType] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMobileCommType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMobileCommType] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMobileCommType] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMobileCommType] TO [public]
GO
