CREATE TABLE [dbo].[tblQCMURFForms]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[MURFSN] [int] NOT NULL,
[FormId] [int] NULL,
[Value] [int] NULL,
[Direction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
