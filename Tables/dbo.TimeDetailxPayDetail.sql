CREATE TABLE [dbo].[TimeDetailxPayDetail]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TimeDetailId] [int] NOT NULL,
[PayDetailId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeDetailxPayDetail] ADD CONSTRAINT [FK_TimeDetailxPayDetail_TimeDetails] FOREIGN KEY ([TimeDetailId]) REFERENCES [dbo].[TimeDetails] ([TimeDetailId])
GO
GRANT DELETE ON  [dbo].[TimeDetailxPayDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeDetailxPayDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeDetailxPayDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeDetailxPayDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeDetailxPayDetail] TO [public]
GO
