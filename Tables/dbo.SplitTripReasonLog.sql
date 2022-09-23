CREATE TABLE [dbo].[SplitTripReasonLog]
(
[splr_number] [int] NOT NULL IDENTITY(1, 1),
[splr_ord_hdrnumber] [int] NOT NULL,
[splr_mov_number] [int] NOT NULL,
[splr_trl_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[splr_reason_desc] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[splr_reason_code] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SplitTripReasonLog] ADD CONSTRAINT [pk_splittripreasonlog_splr_number] PRIMARY KEY CLUSTERED ([splr_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SplitTripReasonLog] TO [public]
GO
GRANT INSERT ON  [dbo].[SplitTripReasonLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SplitTripReasonLog] TO [public]
GO
GRANT SELECT ON  [dbo].[SplitTripReasonLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[SplitTripReasonLog] TO [public]
GO
