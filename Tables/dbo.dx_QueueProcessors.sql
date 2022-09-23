CREATE TABLE [dbo].[dx_QueueProcessors]
(
[qpr_Ident] [int] NOT NULL IDENTITY(1, 1),
[prs_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qpp_Position] [int] NOT NULL,
[que_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[qpr_Wait] [bit] NOT NULL CONSTRAINT [DF_dx_QueueProcessors_QueueProcessorsWait] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueProcessors] ADD CONSTRAINT [PK_dx_QueueProcessors] PRIMARY KEY CLUSTERED ([prs_ID], [qpp_Position], [que_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_QueueProcessors] ADD CONSTRAINT [FK_dx_QueueProcessors_prs_ID] FOREIGN KEY ([prs_ID]) REFERENCES [dbo].[dx_Processor] ([prs_ID])
GO
ALTER TABLE [dbo].[dx_QueueProcessors] ADD CONSTRAINT [FK_dx_QueueProcessors_qpp_Position] FOREIGN KEY ([qpp_Position]) REFERENCES [dbo].[dx_QueueProcessorPosition] ([qpp_Position])
GO
ALTER TABLE [dbo].[dx_QueueProcessors] ADD CONSTRAINT [FK_dx_QueueProcessors_que_ID] FOREIGN KEY ([que_ID]) REFERENCES [dbo].[dx_Queues] ([que_ID])
GO
GRANT DELETE ON  [dbo].[dx_QueueProcessors] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_QueueProcessors] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_QueueProcessors] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_QueueProcessors] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_QueueProcessors] TO [public]
GO
