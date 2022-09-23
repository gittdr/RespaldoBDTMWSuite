CREATE TABLE [dbo].[MobileCommMessageLinkCheckCall]
(
[LinkCheckCallId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[ckc_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkCheckCall] ADD CONSTRAINT [PK_MobileCommMessageLinkCheckCall] PRIMARY KEY CLUSTERED ([LinkCheckCallId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageLinkCheckCall_trc_Number_MessageId] ON [dbo].[MobileCommMessageLinkCheckCall] ([ckc_number], [MessageId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkCheckcall_MessageId_Checkcall] ON [dbo].[MobileCommMessageLinkCheckCall] ([MessageId]) INCLUDE ([ckc_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkCheckCall] ADD CONSTRAINT [FK_MobileCommMessageLinkCheckCall_checkcall_ckc_number] FOREIGN KEY ([ckc_number]) REFERENCES [dbo].[checkcall] ([ckc_number]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkCheckCall] ADD CONSTRAINT [FK_MobileCommMessageLinkCheckCall_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkCheckCall] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkCheckCall] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkCheckCall] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkCheckCall] TO [public]
GO
