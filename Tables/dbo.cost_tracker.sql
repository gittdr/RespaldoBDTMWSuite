CREATE TABLE [dbo].[cost_tracker]
(
[ct_id] [int] NOT NULL IDENTITY(1, 1),
[pyd_number] [int] NULL,
[pyh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[ct_date] [datetime] NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ct_amount] [money] NOT NULL,
[tar_number] [int] NULL,
[ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ct_quantity] [float] NULL,
[ct_isbackout] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ct_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ct_updatesource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cost_tracker] ADD CONSTRAINT [PK__cost_tracker__7141477B] PRIMARY KEY CLUSTERED ([ct_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cost_tracker] TO [public]
GO
GRANT INSERT ON  [dbo].[cost_tracker] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cost_tracker] TO [public]
GO
GRANT SELECT ON  [dbo].[cost_tracker] TO [public]
GO
GRANT UPDATE ON  [dbo].[cost_tracker] TO [public]
GO
