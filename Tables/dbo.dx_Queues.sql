CREATE TABLE [dbo].[dx_Queues]
(
[que_Ident] [bigint] NOT NULL IDENTITY(1, 1),
[que_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[que_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[que_Enabled] [bit] NOT NULL,
[loc_ID_Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_dx_Queues_loc_ID_Source] DEFAULT ((1)),
[loc_ID_Destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_dx_Queues_loc_ID_Destination] DEFAULT ((1)),
[que_RemoveOriginal] [bit] NOT NULL,
[que_CheckInterval] [int] NOT NULL,
[que_FileMask] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[que_Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[que_NewFileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[que_Status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[que_LastRun] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Queues] ADD CONSTRAINT [PK_dx_queues] PRIMARY KEY CLUSTERED ([que_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Queues] ADD CONSTRAINT [FK_dx_Queues_loc_ID_Destination] FOREIGN KEY ([loc_ID_Destination]) REFERENCES [dbo].[dx_QueueLocations] ([loc_ID])
GO
ALTER TABLE [dbo].[dx_Queues] WITH NOCHECK ADD CONSTRAINT [FK_dx_Queues_loc_ID_Source] FOREIGN KEY ([loc_ID_Source]) REFERENCES [dbo].[dx_QueueLocations] ([loc_ID])
GO
GRANT DELETE ON  [dbo].[dx_Queues] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Queues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Queues] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Queues] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Queues] TO [public]
GO
EXEC sp_addextendedproperty N'MS_Description', N'The destination address ID for this Queue from the dx_QueueLocations table.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'loc_ID_Destination'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The source address ID for this Queue from the dx_QueueLocations table.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'loc_ID_Source'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A cyle timer value based in minute increments.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_CheckInterval'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A more fully descriptive value used to describe the purpose of this Queue.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_Description'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Is this Queue enabled in the DX Q Service application.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_Enabled'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A mask used to do a regular expression  comparision on the source address to determine the presence of a desired data source.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_FileMask'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Unique ID for this Queue', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date and time of the last completed cycle upon completion.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_LastRun'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Description Name for this Queue.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The new desired name for the data source after it has been processed by the Queue.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_NewFileName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When this Queue finishes processing does it remove the delete the original file from the souce location address.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_RemoveOriginal'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The current status of the Queue.', 'SCHEMA', N'dbo', 'TABLE', N'dx_Queues', 'COLUMN', N'que_Status'
GO
