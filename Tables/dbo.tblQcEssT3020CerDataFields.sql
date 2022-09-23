CREATE TABLE [dbo].[tblQcEssT3020CerDataFields]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[qcUserIDCompany] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipUnitAddr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[equipID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cerDataOffSetTime] [int] NOT NULL,
[cerDataSpeed] [real] NOT NULL,
[cerDataEventType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cerDataFollowingTime] [real] NOT NULL,
[updatedon] [datetime] NOT NULL,
[updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQcEssT3020CerDataFields] ADD CONSTRAINT [PK_tblQcEssT3020CerDataFields] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblQcEssT3020CerDataFields_Main] ON [dbo].[tblQcEssT3020CerDataFields] ([qcUserIDCompany], [equipUnitAddr], [equipID], [eventKey]) ON [PRIMARY]
GO
