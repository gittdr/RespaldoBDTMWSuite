CREATE TABLE [dbo].[ida_Override]
(
[idOverride] [int] NOT NULL IDENTITY(1, 1),
[idUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[idTractorRecommendation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idDriverRecommendation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idCarrierRecommendation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[curValueRecommendation] [decimal] (18, 0) NULL,
[ValueErrorRecommendation] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idTractorSelection] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idDriverSelection] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idCarrierSelection] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[curValueSelection] [decimal] (18, 0) NULL,
[ValueErrorSelection] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idReason] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sComments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtmCreated] [datetime] NOT NULL CONSTRAINT [DF_ida_Override_dtmCreated] DEFAULT (getdate()),
[lgh_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ida_Override] ADD CONSTRAINT [PK_ida_Override] PRIMARY KEY CLUSTERED ([idOverride]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ida_Override] TO [public]
GO
GRANT INSERT ON  [dbo].[ida_Override] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ida_Override] TO [public]
GO
GRANT SELECT ON  [dbo].[ida_Override] TO [public]
GO
GRANT UPDATE ON  [dbo].[ida_Override] TO [public]
GO
