CREATE TABLE [dbo].[dx_QueueProcessorPosition]
(
[qpp_Ident] [int] NOT NULL IDENTITY(1, 1),
[qpp_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qpp_Position] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueProcessorPosition] ADD CONSTRAINT [PK_dx_QueueProcessorPosition] PRIMARY KEY CLUSTERED ([qpp_Position]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_QueueProcessorPosition] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_QueueProcessorPosition] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_QueueProcessorPosition] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_QueueProcessorPosition] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_QueueProcessorPosition] TO [public]
GO
