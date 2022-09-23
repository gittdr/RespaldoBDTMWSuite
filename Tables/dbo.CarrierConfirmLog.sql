CREATE TABLE [dbo].[CarrierConfirmLog]
(
[ccl_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NOT NULL,
[ccl_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_senttype] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_sentid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccl_amount] [decimal] (19, 4) NULL,
[ccl_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccl_lastupdated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierConfirmLog] ADD CONSTRAINT [PK_CarrierConfirmLog] PRIMARY KEY CLUSTERED ([ccl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierConfirmLog_LghNumber] ON [dbo].[CarrierConfirmLog] ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierConfirmLog] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierConfirmLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierConfirmLog] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierConfirmLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierConfirmLog] TO [public]
GO
