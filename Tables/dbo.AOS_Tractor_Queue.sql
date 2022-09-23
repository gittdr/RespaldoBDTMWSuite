CREATE TABLE [dbo].[AOS_Tractor_Queue]
(
[atq_id] [int] NOT NULL IDENTITY(1, 1),
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[insert_datetime] [datetime] NULL CONSTRAINT [DF_AOS_Tractor_Queue_Datetime] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AOS_Tractor_Queue] ADD CONSTRAINT [PK_AOS_Tractor_Queue] PRIMARY KEY CLUSTERED ([atq_id]) ON [PRIMARY]
GO
