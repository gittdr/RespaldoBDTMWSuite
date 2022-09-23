CREATE TABLE [dbo].[tblQcEssProximity]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[qcUserIDCompany] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipUnitAddr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[essEvent] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventField] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[seq] [int] NOT NULL,
[distance] [real] NOT NULL,
[direction] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeAlias] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeAlias2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeAlias3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeAlias4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeAlias5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[placeType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stateProv] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[postal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[country] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedon] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQcEssProximity] ADD CONSTRAINT [PK_tblQcEssProximity] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQcEssProximity_Main] ON [dbo].[tblQcEssProximity] ([qcUserIDCompany], [equipUnitAddr], [equipID], [essEvent], [eventKey], [eventField], [seq]) ON [PRIMARY]
GO
