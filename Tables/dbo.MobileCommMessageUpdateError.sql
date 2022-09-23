CREATE TABLE [dbo].[MobileCommMessageUpdateError]
(
[ErrorId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[ErrorMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreventUpdate] [bit] NOT NULL,
[ErrorType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDate] [datetime] NOT NULL CONSTRAINT [df_MobileCommMessageUpdateError_ErrorDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageUpdateError] ADD CONSTRAINT [PK_MobileCommMessageUpdateError] PRIMARY KEY CLUSTERED ([ErrorId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageUpdateError_MessageId] ON [dbo].[MobileCommMessageUpdateError] ([MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageUpdateError] ADD CONSTRAINT [FK_MobileCommMessageUpdateError_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageUpdateError] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageUpdateError] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageUpdateError] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageUpdateError] TO [public]
GO
