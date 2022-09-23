CREATE TABLE [dbo].[tblErrorData_archive]
(
[SN] [int] NOT NULL,
[VBError] [int] NULL,
[Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [datetime] NULL,
[ErrListID] [int] NULL,
[ts] [timestamp] NULL,
[View] [int] NULL,
[Page] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrorData_archive] ADD CONSTRAINT [PK_tblErrorData_archive] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
