CREATE TABLE [dbo].[min_profit_override]
(
[mpo_id] [int] NOT NULL IDENTITY(1, 1),
[mpo_override_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpo_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[mpo_loggedin_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpo_estimated_profit] [decimal] (18, 4) NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[min_profit_override] TO [public]
GO
GRANT REFERENCES ON  [dbo].[min_profit_override] TO [public]
GO
GRANT SELECT ON  [dbo].[min_profit_override] TO [public]
GO
GRANT UPDATE ON  [dbo].[min_profit_override] TO [public]
GO
