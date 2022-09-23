CREATE TABLE [dbo].[dx_Processor]
(
[prs_Ident] [int] NOT NULL IDENTITY(1, 1),
[prs_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_dx_Processor_ProcessorID] DEFAULT ('Unknown'),
[prs_Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prs_Application_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prs_Path] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prs_Command_Line] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_TimeOut] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Processor] ADD CONSTRAINT [PK_dx_Processor] PRIMARY KEY CLUSTERED ([prs_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Processor] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Processor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Processor] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Processor] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Processor] TO [public]
GO
