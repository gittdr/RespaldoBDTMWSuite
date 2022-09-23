CREATE TABLE [dbo].[laneauction_messagelog]
(
[lam_identity] [int] NOT NULL IDENTITY(1, 1),
[lam_batch_nbr] [int] NOT NULL,
[lam_transaction_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_item] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_item_msg] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_itemkey] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_IWE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lam_create_date] [datetime] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[ca_id] [int] NULL,
[tariffkeybid_tar_number] [int] NULL,
[tariffkey_tar_number] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ca_id] ON [dbo].[laneauction_messagelog] ([ca_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lam_batch_nbr] ON [dbo].[laneauction_messagelog] ([lam_batch_nbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_lam_identity] ON [dbo].[laneauction_messagelog] ([lam_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[laneauction_messagelog] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[laneauction_messagelog] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[laneauction_messagelog] TO [public]
GO
GRANT INSERT ON  [dbo].[laneauction_messagelog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[laneauction_messagelog] TO [public]
GO
GRANT SELECT ON  [dbo].[laneauction_messagelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[laneauction_messagelog] TO [public]
GO
