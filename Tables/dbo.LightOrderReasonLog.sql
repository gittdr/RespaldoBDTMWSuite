CREATE TABLE [dbo].[LightOrderReasonLog]
(
[reason_key] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[reason_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reason_desc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[note] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[required_qty] [decimal] (9, 2) NULL,
[ordered_qty] [decimal] (9, 2) NULL,
[consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reason_userstamp] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reason_timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LightOrderReasonLog] ADD CONSTRAINT [pk_LightOrderReasonLog] PRIMARY KEY CLUSTERED ([reason_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LightOrderReasonLog] TO [public]
GO
GRANT INSERT ON  [dbo].[LightOrderReasonLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LightOrderReasonLog] TO [public]
GO
GRANT SELECT ON  [dbo].[LightOrderReasonLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[LightOrderReasonLog] TO [public]
GO
