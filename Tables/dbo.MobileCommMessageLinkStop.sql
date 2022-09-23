CREATE TABLE [dbo].[MobileCommMessageLinkStop]
(
[LinkStopId] [bigint] NOT NULL IDENTITY(1, 1),
[MessageId] [bigint] NOT NULL,
[stp_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkStop] ADD CONSTRAINT [PK_MobileCommMessageLinkStop] PRIMARY KEY CLUSTERED ([LinkStopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_MobileCommMessageLinkStop_MessageId_StopNumber] ON [dbo].[MobileCommMessageLinkStop] ([MessageId]) INCLUDE ([stp_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_MobileCommMessageLinkStop_trc_Number_MessageId] ON [dbo].[MobileCommMessageLinkStop] ([stp_number], [MessageId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageLinkStop] ADD CONSTRAINT [FK_MobileCommMessageLinkStop_MobileCommMessageInstance_MessageId] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MobileCommMessage] ([MessageId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MobileCommMessageLinkStop] ADD CONSTRAINT [FK_MobileCommMessageLinkStop_Stops_stp_number] FOREIGN KEY ([stp_number]) REFERENCES [dbo].[stops] ([stp_number]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[MobileCommMessageLinkStop] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageLinkStop] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageLinkStop] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageLinkStop] TO [public]
GO
